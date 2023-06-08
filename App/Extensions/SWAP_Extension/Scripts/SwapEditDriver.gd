extends VBoxContainer

#-- Scene Refs
onready var type_select = $TypePanel/VBoxContainer/TypeSelect
onready var forms_panel = $FormsPanel
onready var comment_panel = $CommentPanel
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

#--- Called by system to apply changes to the ini edit.
func apply_edit(interp):
	pass

#--- CUSTOM: Handles drawing the ui.
func draw_panels(edit):
	pass
