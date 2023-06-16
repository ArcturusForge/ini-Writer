extends Node

var parserPath = "res://App/Extensions/SWAP_Extension/Scripts/Utils/Inline_Parser.gd"
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
			"excludes":[":<"]
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
		":<":{
			"id":4,
			"excludes":[]
		}
	}
	var parsed_lines = parser.split_and_define_lines(raw, symbols)
	for lineData in parsed_lines:
		var edit = new_edit()
		var currentHeader = {
			"type":-1,
			"data":""
		}
		var attachedComment = null
#		{
#			"name":"",
#			"content":"",
#			"lineNumber":0
#		}
		match lineData.type:
			-1:#- Comment
				edit.notation.comment = lineData.line
				interp.edits.append(edit)
			0:#- Form Header
				currentHeader.type = 0
				if "|" in lineData.line:
					currentHeader.data = lineData.line.replace("[Forms|", "").replace("]", "")
				else:
					currentHeader.data = ""
			1:#- Reference Header
				currentHeader.type = 1
				if "|" in lineData.line:
					currentHeader.data = lineData.line.replace("[References|", "").replace("]", "")
				else:
					currentHeader.data = ""
			2:#- Transform Header
				currentHeader.type = 2
				if "|" in lineData.line:
					currentHeader.data = lineData.line.replace("[Transforms|", "").replace("]", "")
				else:
					currentHeader.data = ""
			3:#- Edit
				edit.editType = currentHeader.type
				edit.restrictions = currentHeader.data.split(",", false)
				
				if attachedComment != null:
					edit.notation.name = attachedComment.name
					edit.notation.comment = attachedComment.content
					edit.notation.lineStart = attachedComment.lineNumber
				else:
					edit.notation.lineStart = lineData.line_number
					edit.notation.lineEnd = lineData.line_number
				
				var segments = lineData.line.split("|")
				for i in range(segments.size):
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
							var transforms = segment.split("),", false)
							for tran in transforms:
								if "pos" in 
							edit.transform.position
						3:#- Chance
				
				interp.edits.append(edit)
			4:#- Comment line attached to edit.
				
		
	return {}

#--- SYSTEM: Compiles the interp data into raw string format for ini-extension syntax.
func interp_to_raw(interp): # interp = {}
	return ""

#--- SYSTEM: Intercepts the filesave process to alter the file name before it is saved.
func alter_save_name(originalName:String):
	return originalName

#--- SYSTEM: Moves an edit from the origIndex to the targetIndex.
func move_index_to(interp, origIndex, targetIndex):
	pass

#--- SYSTEM: Returns the total amount of edits in the interp data.
func get_edit_count(interp):
	return 0

#--- SYSTEM: Returns the name of an edit inside the interp data.
func get_edit_name(interp, index):
	return ""

#--- SYSTEM: Called by the system to remove an edit from circulation.
func delete_edit(index, interp):
	pass
