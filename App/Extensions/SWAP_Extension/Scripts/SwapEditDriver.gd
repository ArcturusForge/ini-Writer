extends VBoxContainer

#-- Scene Refs
onready var type_select = $TypePanel/VBoxContainer/TypeSelect
onready var comment_panel = $CommentPanel
onready var name_container = $CommentPanel/VBoxContainer/NameContainer
onready var restrictions_panel = $RestrictionsPanel
onready var source_panel = $SourcePanel
onready var targets_panel = $TargetsPanel
onready var transform_panel = $TransformPanel
onready var chance_panel = $ChancePanel

#-- Dynamic Vars
var workingIndex:int = -1 #- Points towards the index for this ini edit.
var system #- Points towards the editor window manager.
var interpreter #- The interpreter script from this particular extension.

#--- Called by system to initialize the driver.
func init_driver(workingIndex, system, interpreter):
	self.workingIndex = workingIndex
	self.system = system
	self.interpreter = interpreter
	type_select.connect("item_selected", self, "handle_toggle")
	pass

#--- Called by system to modify an existing ini edit.
func modify_existing(interp):
	draw_panels(interp.edits[workingIndex])
	pass

#--- Called by system to write a new ini edit.
func create_new():
	draw_panels(interpreter.new_edit())
	pass

#--- Call this to notify the system of changes made.
func notify_system():
	system.alert_to_edits()
	pass

#--- Called by system to apply changes to the ini edit.
func apply_edit(interp):
	var edit = interpreter.new_edit()
	
	pass

#--- CUSTOM: Handles drawing the ui.
func draw_panels(edit):
	comment_panel.set_data(edit)
	restrictions_panel.set_data(edit)
	source_panel.set_data(edit)
	targets_panel.set_data(edit)
#	transform_panel.set_data(edit)
#	chance_panel.set_data(edit)
	
	handle_toggle(edit.editType + 1) #- Plus 1 because function is designed for MenuOption indexing.
	pass

#--- CUSTOM: automates panel toggling.
func handle_toggle(index:int):
	match index:
		0:
			toggle_panels(false, false, false, false, false, false)
		1,2:
			toggle_panels(true, true, true, true, true, true)
		3:
			toggle_panels(true, true, true, false, true, true)

#--- CUSTOM: Toggles ui panels.
func toggle_panels(a:bool, b:bool, c:bool, d:bool, e:bool, f:bool):
	name_container.visible = a
	restrictions_panel.visible = b
	source_panel.visible = c
	targets_panel.visible = d
	transform_panel.visible = e
	chance_panel.visible = f
	pass
