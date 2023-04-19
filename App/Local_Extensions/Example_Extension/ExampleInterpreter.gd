extends Node

#--- Determines wether ini file matches extension use-case.
func data_matched(raw:String, fileName:String):
	return false

#--- Interpretes the raw string data to data structures used in editor.
func raw_to_interp(raw:String):
	return {}

#--- Compiles the interp data into raw string format for ini-extension syntax.
func interp_to_raw(interp): # interp = {}
	return ""

#--- Intercepts the filesave process to alter the file name before it is saved.
func alter_save_name(originalName:String):
	return originalName

#--- Moves an edit from the origIndex to the targetIndex.
func move_index_to(interp, origIndex, targetIndex):
	pass

#--- Returns the total amount of edits in the interp data.
func get_edit_count(interp):
	return 0

#--- Returns the name of an edit inside the interp data.
func get_edit_name(interp, index):
	return ""
