extends VBoxContainer

#-- Dynamic Vars
var workingIndex:int = -1 #- Points towards the index for this ini edit.
var system #- Points towards the editor window manager.
var interpreter #- The interpreter script from this particular extension.

#--- Called by system to initialize the driver.
func init_driver(workingIndex, system, interpreter):
	self.workingIndex = workingIndex
	self.system = system
	self.interpreter = interpreter
	pass

#--- Called by system to modify an existing ini edit.
func modify_existing(interp):
	pass

#--- Called by system to write a new ini edit.
func create_new():
	pass

#--- Call this to notify the system of changes made.
func notify_system():
	system.alert_to_edits()
	pass

#--- Call this to cancel editing.
func cancel_edit():
	system.cancel_create()
	pass

#--- Called by system to apply changes to the ini edit.
func apply_edit(interp):
	pass
