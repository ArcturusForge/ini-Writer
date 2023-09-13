extends Node

#--- SYSTEM: Determines if ini file matches extension use-case.
func data_matched(raw:String, fileName:String):
	if "_CID" in fileName:
		return true
	return false

#--- SYSTEM: Called by system when the extension is enabled.
func enable():
	pass

#--- SYSTEM: Called by system when the extension is disabled.
func disable():
	pass

#--- SYSTEM: Called by system to structure interp data to be compatible with extension.
func init_interp():
	var interp = {
		
	}
	return interp

#--- SYSTEM: Interpretes the raw string data to data structures used in editor.
func raw_to_interp(raw:String):
	return {}

#--- SYSTEM: Compiles the interp data into raw string format for ini-extension syntax.
func interp_to_raw(interp): # interp = {}
	return ""

#--- SYSTEM: Intercepts the filesave process to alter the file name before it is saved.
func alter_save_name(originalName:String):
	if not "_CID" in originalName:
		originalName += "_CID"
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

#--- CUSTOM: Quick method to create a new edit dataset.
func new_edit():
	var edit = {
		"type":0, #- (0)Comment, (1)Add, (2)Remove, (3)RemoveAll, (4)Replace, (5)ReplaceAll
		"container":"",
		"target":"",
		"notes":{
			"name":"",
			"comment":"",
			"newlines":0
		}
	}
	return edit
