extends Node

#--- Determines wether ini file matches extension use-case.
func data_matched(raw:String):
	return false

#--- Interpretes the raw string data to data structures used in editor.
func raw_to_interp(raw:String):
	return {}

#--- Compiles the interp data into raw string format for ini syntax.
func interp_to_raw(interp): # interp = {}
	return ""
	
