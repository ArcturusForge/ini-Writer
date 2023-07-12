extends Node

var parserPath = "res://App/Extensions/BOS_Extension/Scripts/Utils/Inline_Parser.gd"
var parser

#--- SYSTEM: Determines if ini file matches extension use-case.
func data_matched(raw:String, fileName:String):
	return false

#--- SYSTEM: Called by system when the extension is enabled.
func enable():
	parser = ResourceLoader.load(parserPath).new()
	pass

#--- SYSTEM: Called by system when the extension is disabled.
func disable():
	parser = null
	pass

#--- SYSTEM: Called by system to structure interp data to be compatible with extension.
func init_interp():
	var interp = {
		"edits":[]
	}
	return interp

#--- CUSTOM: Quick method to create a new edit dataset.
func new_edit():
	var edit = {
		"editType":-1, #- (-1)Comment, (0)Forms, (1)Refs, (2)Transforms
		"notation":{
			"name":"",
			"comment":"",
			"newlines":1,
			"lineStart":0,
			"lineEnd":0
		},
		"restrictions": [],
		"target":"",
		"replacements":[],
		"transform":{
			"position":"",
			"rotation":"",
			"scale":""
		},
		"chance":""
	}
	return edit

#--- SYSTEM: Interpretes the raw string data to data structures used in editor.
func raw_to_interp(raw:String):
	var interp = init_interp()
	var symbols = {
		";":{
			"id":-1,
			"excludes":[";<"]
		},
		"[Forms":{
			"id":0,
			"excludes":[]
		},
		"[References":{
			"id":1,
			"excludes":[]
		},
		"[Transforms":{
			"id":2,
			"excludes":[]
		},
		"|":{
			"id":3,
			"excludes":[
				"[Forms", 
				"[References", 
				"[Transforms"
			]
		},
		";<":{
			"id":4,
			"excludes":[]
		}
	}
	var parsed_lines = parser.split_and_define_lines(raw, symbols)
	var currentHeader = {
			"type":-1,
			"data":"",
			"lineNum":0,
			"used":0
		}
	var attachedComment = null
#		{
#			"name":"",
#			"content":"",
#			"lineNumber":0
#		}
	
	var currentIndex = -1 #- Only modified when SWAP edits are detected.
	for lineData in parsed_lines:
		var edit = new_edit()
		
		match lineData.type:
			-2:#- Empty line
				if interp.edits.size() > 0 && currentIndex > 0:
					var prevEdit = interp.edits[currentIndex - 1]
					prevEdit.notation.newlines += 1
			-1:#- Comment
					currentIndex += 1
					var line:String = lineData.line
					var e = 0
					while line[e] != ";":
						e += 1
					line[e] = ""
					edit.notation.comment = line
					edit.notation.lineEnd = lineData.line_number
					edit.notation.lineStart = lineData.line_number
					interp.edits.append(edit)
			0:#- Form Header
				currentHeader.type = 0
				currentHeader.used = 0
				currentHeader.lineNum = lineData.line_number
				if "|" in lineData.line:
					currentHeader.data = lineData.line.replace("[Forms|", "").replace("]", "")
				else:
					currentHeader.data = ""
			1:#- Reference Header
				currentHeader.type = 1
				currentHeader.used = 0
				currentHeader.lineNum = lineData.line_number
				if "|" in lineData.line:
					currentHeader.data = lineData.line.replace("[References|", "").replace("]", "")
				else:
					currentHeader.data = ""
			2:#- Transform Header
				currentHeader.type = 2
				currentHeader.used = 0
				currentHeader.lineNum = lineData.line_number
				if "|" in lineData.line:
					currentHeader.data = lineData.line.replace("[Transforms|", "").replace("]", "")
				else:
					currentHeader.data = ""
			3:#- Edit
				currentIndex += 1
				edit.editType = currentHeader.type
				edit.restrictions = currentHeader.data.split(",", false)
				edit.notation.lineEnd = lineData.line_number
				
				if attachedComment != null:
					edit.notation.name = attachedComment.name
					edit.notation.comment = attachedComment.content
					edit.notation.lineStart = attachedComment.lineNumber
					attachedComment = null
				else:
					edit.notation.lineStart = lineData.line_number
				
				if currentHeader.used == 0:
					edit.notation.lineStart = currentHeader.lineNum
					currentHeader.used += 1
				
				var segments = lineData.line.split("|")
				for i in range(segments.size()):
					#- Cache segment string
					var segment:String = segments[i]
					#- Transform edits skip SwapIDs so we need to bump index up one.
					if edit.editType == 2 && i == 1:
						i += 1
					
					match i:
						0:#- TargetID
							edit.target = segment
						1:#- SwapIDs
							edit.replacements = segment.split(",", false)
						2:#- TransformOverrides
							if "NONE" in segment:
								continue
							var transforms = segment.split("),", false)
							for tran in transforms:
								if "pos" in tran:
									edit.transform.position = tran
								elif "rot" in tran:
									edit.transform.rotation = tran
								elif "scale" in tran:
									edit.transform.scale = tran
						3:#- Chance
							if "NONE" in segment:
								continue
							edit.chance = segment
				interp.edits.append(edit)
			4:#- Comment line attached to edit.
				attachedComment = {
					"name":lineData.line.get_slice(">", 0).replace(";<", ""),
					"content":lineData.line.get_slice(">", 1),
					"lineNumber":lineData.line_number
				}
		
	return interp

#--- SYSTEM: Compiles the interp data into raw string format for ini-extension syntax.
func interp_to_raw(interp): # interp = {}
	var final = ""
	var prevEdit = null
	
	for x in range(interp.edits.size()):
		var edit = interp.edits[x]
		#- (-1)Comment, (0)Forms, (1)Refs, (2)Transforms
		match edit.editType:
			-1:
				final += ";" + edit.notation.comment
			0,1,2:
				if prevEdit == null || edit.editType != prevEdit.editType || !array_match(edit.restrictions, prevEdit.restrictions):
					match edit.editType:
						0:
							final += "[Forms"
						1:
							final += "[References"
						2:
							final += "[Transforms"
					if edit.restrictions.size() > 0 && edit.editType != 1:
						final += "|"
						for i in range(edit.restrictions.size()):
							final += edit.restrictions[i]
							if i < edit.restrictions.size() - 1:
								final += ","
					final += "]\n"
				prevEdit = edit
				
				#- Handle the edit's comment data
				if edit.notation.comment != "" || edit.notation.name != "" :
					final += ";<" + edit.notation.name + ">" + edit.notation.comment + "\n"
				
				#- Handle the target data
				final += edit.target + "|"
				
				#- Handle the replacement data
				if edit.replacements.size() > 0 && not edit.editType == 2:
					for i in range(edit.replacements.size()):
						final += edit.replacements[i]
						if i < edit.replacements.size() - 1:
								final += ","
					final += "|"
				
				#- Handle the Transform data
				if edit.transform.position == "" && edit.transform.rotation == "" && edit.transform.scale == "":
					final += "NONE|"
				else:
					var transforms = ""
					if edit.transform.position != "":
						transforms += edit.transform.position
					if edit.transform.rotation != "":
						if transforms != "":
							transforms += ","
						transforms += edit.transform.rotation
					if edit.transform.scale != "":
						if transforms != "":
							transforms += ","
						transforms += edit.transform.scale
					final += transforms + "|"
				
				#- Handle the chance data.
				if edit.chance != "":
					final += edit.chance
				else:
					final += "chanceS(100)"
				
		
		#- Handle newline adding here.
		var i = 0
		if x < interp.edits.size() - 1:
			while i < edit.notation.newlines:
				final += "\n"
				i += 1
		
	#- Text Cleaning pass.
	final = final.replace("|NONE|chanceS(100)", "")
	final = final.replace("|chanceS(100)", "")
	return final

#--- SYSTEM: Intercepts the filesave process to alter the file name before it is saved.
func alter_save_name(originalName:String):
	if not "_SWAP" in originalName:
		originalName += "_SWAP"
	return originalName

#--- SYSTEM: Moves an edit from the origIndex to the targetIndex.
func move_index_to(interp, origIndex, targetIndex):
	var data = interp.edits[origIndex]
	interp.edits.remove(origIndex)
	interp.edits.insert(targetIndex, data)
	pass

#--- SYSTEM: Returns the total amount of edits in the interp data.
func get_edit_count(interp):
	return interp.edits.size()

#--- SYSTEM: Returns the name of an edit inside the interp data.
func get_edit_name(interp, index):
	var edit = interp.edits[index]
	var eName = ""
	match edit.editType:
		-1: #- (-1)Comment
			eName += str(edit.notation.lineStart)
			eName += " Comment: " + edit.notation.comment
			return eName
		0,1,2: #- (0)Forms, (1)Refs, (2)Transforms
			eName += str(edit.notation.lineStart) + "~" if (edit.notation.lineStart != edit.notation.lineEnd) else ""
			eName += str(edit.notation.lineEnd) + " "
			eName += get_type_name(edit.editType) + ": "
	if edit.notation.name == "":
		eName += edit.target
	else:
		eName += edit.notation.name
	return eName

#--- SYSTEM: Called by the system to remove an edit from circulation.
func delete_edit(index, interp):
	interp.edits.remove(index)
	pass

#--- CUSTOM: Used to get the name from each edit type.
func get_type_name(type):
	#(-1)Comment, (0)Forms, (1)Refs, (2)Transforms
	match type:
		-1:
			return "Comment"
		0:
			return "Form"
		1:
			return "Reference"
		2:
			return "Transform"
	return "Un-typed"

#--- CUSTOM: Returns bool based on two arrays' elements matching.
func array_match(a:Array, b:Array):
	if a.size() != b.size():
		return false
	
	for i in range(a.size()):
		if a[i] != b[i]:
			return false
	return true
