extends Node

var parserPath = "res://App/Extensions/CID_Extension/Scripts/Utils/Inline_Parser.gd"
var parser

#--- SYSTEM: Determines if ini file matches extension use-case.
func data_matched(raw:String, fileName:String):
	if "_CID" in fileName:
		return true
	return false
	

#--- SYSTEM: Called by system when the extension is enabled.
func enable():
	Globals.Version_Check("2.0.0")
	parser = ResourceLoader.load(parserPath).new()
	var ver = Globals.config.versionId.split(".")

#--- SYSTEM: Called by system when the extension is disabled.
func disable():
	parser = null
	

#--- SYSTEM: Called by system to structure interp data to be compatible with extension.
func init_interp():
	var interp = {
		"edits":[]
	}
	return interp
	

#--- SYSTEM: Interpretes the raw string data to data structures used in editor.
func raw_to_interp(raw:String):
	var interp = init_interp()
	var symbols = {
		";":{#- Comment
			"id":-1,
			"excludes":[";["]
		},
		";[":{#- Attached Comment
			"id":0,
			"excludes":[]
		},
		"-":{#- Remove Variant
			"id":1,
			"excludes":[]
		},
		"^":{#- Replace Variant
			"id":2,
			"excludes":[]
		},
		"=":{#- Add
			"id":3,
			"excludes":[]
		}
	}
	var parsed_lines = parser.split_and_define_lines(raw, symbols)
	var attachedComment = null
#		{
#			"name":"",
#			"content":"",
#			"lineNumber":0
#		}
	
	var currentIndex = -1 #- Only modified when edits are detected.
	for lineData in parsed_lines:
		var edit = new_edit()
		
		match lineData.type:
			-2:#- Empty line
				if interp.edits.size() > 0 && currentIndex > 0:
					var prevEdit = interp.edits[currentIndex]
					prevEdit.notes.newlines += 1
			-1:#- Comment
					currentIndex += 1
					var line:String = lineData.line
					var e = 0
					while line[e] != ";":
						e += 1
					line[e] = ""
					edit.notes.comment = line
					edit.notes.lineEnd = lineData.line_number
					edit.notes.lineStart = lineData.line_number
					edit.type = 0
					interp.edits.append(edit)
			0:#- Attached Comment
				attachedComment = {
					"name":lineData.line.get_slice("]", 0).replace(";[", ""),
					"content":lineData.line.get_slice("]", 1),
					"lineNumber":lineData.line_number
				}
			1:#- Remove Variant
				currentIndex += 1
				edit.notes.lineEnd = lineData.line_number
				
				if attachedComment != null:
					edit.notes.name = attachedComment.name
					edit.notes.comment = attachedComment.content
					edit.notes.lineStart = attachedComment.lineNumber
					attachedComment = null
				else:
					edit.notes.lineStart = lineData.line_number
				
				edit.container = lineData.line.get_slice(" = ", 0)
				var target :String = lineData.line.get_slice(" = ", 1)
				edit.target = target
				if "|" in edit.target:#- Remove
					edit.type = 2
				else:#- RemoveAll
					edit.type = 3
				interp.edits.append(edit)
			2:#- Replace Variant
				currentIndex += 1
				edit.notes.lineEnd = lineData.line_number
				
				if attachedComment != null:
					edit.notes.name = attachedComment.name
					edit.notes.comment = attachedComment.content
					edit.notes.lineStart = attachedComment.lineNumber
					attachedComment = null
				else:
					edit.notes.lineStart = lineData.line_number
				
				edit.container = lineData.line.get_slice(" = ", 0)
				edit.target = lineData.line.get_slice(" = ", 1)
				var dps = edit.target.split("^")
				if "|" in dps[0]:#- Replace
					edit.type = 4
				else:#- ReplaceAll
					edit.type = 5
				interp.edits.append(edit)
			3:#- Add
				currentIndex += 1
				edit.notes.lineEnd = lineData.line_number
				
				if attachedComment != null:
					edit.notes.name = attachedComment.name
					edit.notes.comment = attachedComment.content
					edit.notes.lineStart = attachedComment.lineNumber
					attachedComment = null
				else:
					edit.notes.lineStart = lineData.line_number
				
				edit.container = lineData.line.get_slice(" = ", 0)
				edit.target = lineData.line.get_slice(" = ", 1)
				edit.type = 1
				interp.edits.append(edit)
	return interp
	

#--- SYSTEM: Compiles the interp data into raw string format for ini-extension syntax.
func interp_to_raw(interp): # interp = {}
	var final = ""
	final += "[General]\n"
	for i in range(interp.edits.size()):
		var edit = interp.edits[i]
		match edit.type:
			0:#- Comment
				final += ";" + edit.notes.comment
			1,2,3,4,5:#- Add/Remove/RemoveAll/Replace/ReplaceAll
				if edit.notes.comment != "" || edit.notes.name != "" :
					final += ";[" + edit.notes.name + "]" + edit.notes.comment + "\n"
				final += edit.container + " = " + edit.target
		
		if i < interp.edits.size()-1: #- Skip this because the textbox auto adds a \n to the end of the text anyway.
			final += "\n"
		for x in range(edit.notes.newlines):
			final += "\n"
#		final = final.replace("  ", " ")
	return final
	

#--- SYSTEM: Intercepts the filesave process to alter the file name before it is saved.
func alter_save_name(originalName:String):
	if not "_CID" in originalName:
		originalName += "_CID"
	return originalName
	

#--- SYSTEM: Moves an edit from the origIndex to the targetIndex.
func move_index_to(interp, origIndex, targetIndex):
	var data = interp.edits[origIndex]
	interp.edits.remove(origIndex)
	interp.edits.insert(targetIndex, data)
	

#--- SYSTEM: Returns the total amount of edits in the interp data.
func get_edit_count(interp):
	return interp.edits.size()
	

#--- SYSTEM: Returns the name of an edit inside the interp data.
func get_edit_name(interp, index):
	var edit = interp.edits[index]
	var eName = ""
	match edit.type:
		0: #- (0)Comment
			eName += str(edit.notes.lineStart)
			eName += " Comment: " + edit.notes.comment
			return eName
		1,2,3,4,5: #- (1)Add, (2)Remove, (3)RemoveAll, (4)Replace, (5)ReplaceAll
			eName += str(edit.notes.lineStart) + "~" if (edit.notes.lineStart != edit.notes.lineEnd) else ""
			eName += str(edit.notes.lineEnd) + " "
			eName += get_type_name(edit.type) + ": "
	if edit.notes.name == "":
		eName += edit.target
	else:
		eName += edit.notes.name
	return eName
	

#--- SYSTEM: Called by the system to remove an edit from circulation.
func delete_edit(index, interp):
	interp.edits.remove(index)
	

#--- CUSTOM: Quick method to create a new edit dataset.
func new_edit():
	var edit = {
		"type":0, #- (0)Comment, (1)Add, (2)Remove, (3)RemoveAll, (4)Replace, (5)ReplaceAll
		"container":"",
		"target":"",
		"notes":{
			"name":"",
			"comment":"",
			"newlines":0,
			"lineStart":0,
			"lineEnd":0
		}
	}
	return edit
	

func get_type_name(type):
	#- (0)Comment, (1)Add, (2)Remove, (3)RemoveAll, (4)Replace, (5)ReplaceAll
	match type:
		0:
			return "Comment"
		1:
			return "Add"
		2:
			return "Remove"
		3:
			return "RemoveAll"
		4:
			return "Replace"
		5:
			return "ReplaceAll"
	return "Un-typed"
	
