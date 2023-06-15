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
	return interp

#--- SYSTEM: Interpretes the raw string data to data structures used in editor.
func raw_to_interp(raw:String):
	var symbols = {
		";":-1,
		"[Forms":0,
		"[References":1,
		"[Transforms":2,
		"|":3
	}
	var parsed_lines = parser.split_and_define_lines(raw, symbols)
	for line in parsed_lines:
		match line.type:
			-1:#- Comment
			0:#- Form Header
			1:#- Reference Header
			2:#- Transform Header
			3:#- Edit
			
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
