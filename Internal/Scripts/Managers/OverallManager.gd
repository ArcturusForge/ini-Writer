extends Control

#-- Constants
const my_id = "overall"

#-- Managers
onready var search_manager = $"../SearchManager"
onready var window_manager = $"../WindowManager"
onready var raw_manager = $"../RawManager"
onready var editor_manager = $"../EditorManager"
onready var color_manager = $"../ColorManager"
onready var console_manager = $"../ConsoleManager"

#-- Dynamic Vars
var extension = {
	#_TEMP: Temp val assign
	"interpreter":"res://App/Extensions/SPID_Extension/Scripts/SpidInterpreter.gd",
	"editor":"res://App/Extensions/SPID_Extension/Interfaces/SpidEditDisplay.tscn"
}
var activeInterpreter

func _ready():
	Globals.set_manager(my_id, self)
	search_manager.jump_start()
	console_manager.jump_start()
	editor_manager.jump_start()
	raw_manager.jump_start()
	
	#_TEMP
	activeInterpreter = load(extension.interpreter).new()
	Session.data.interp = activeInterpreter.init_interp()
	pass

#--- Regenerates both editors.
func repaint_editors():
	repaint_interp_editor()
	repaint_raw_editor()
	pass

#--- Regenerates the interp editor window.
func repaint_interp_editor():
#	if activeInterpreter.get_edit_count(Session.data.interp) == 0:
#		return
	var nameArray = []
	for i in activeInterpreter.get_edit_count(Session.data.interp):
		nameArray.append(activeInterpreter.get_edit_name(Session.data.interp, i))
	editor_manager.update_editor(nameArray)
	pass

#--- Regenerates the raw editor window.
func repaint_raw_editor():
	raw_manager.update_editor()
	pass

func move_edit_selector(originalIndex, newIndex):
	activeInterpreter.move_index_to(Session.data.interp, originalIndex, newIndex)
	var raw = activeInterpreter.interp_to_raw(Session.data.interp)
	Session.data.raw = raw
	repaint_editors()
	pass
