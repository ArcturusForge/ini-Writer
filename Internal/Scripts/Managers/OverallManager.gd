extends Control

#-- Constants
const my_id = "overall"

#-- FileMenu Constants
const openOption = "Open ini"
const openFileOption = "Open Folder Location"
const saveOption = "Save ini"
const saveAsOption = "Save As..."
const exportOption = "Export ini"
const prefsOption = "Preferences"
#-- ViewMenu Constants
const creatorOption = "Creator's Page"
const spidOption = "SPID Mod Page"
const vid1Option = "SPID Video Guide 1"
const vid2Option = "SPID Video Guide 2"

#-- Managers
onready var search_manager = $"../SearchManager"
onready var window_manager = $"../WindowManager"
onready var raw_manager = $"../RawManager"
onready var editor_manager = $"../EditorManager"
onready var color_manager = $"../ColorManager"
onready var console_manager = $"../ConsoleManager"
onready var popup_manager = $"../PopupManager"

#-- Scene Refs
onready var file_menu = $"../../Interface/VBoxContainer/TopBar/FileMenu"
onready var view_menu = $"../../Interface/VBoxContainer/TopBar/ViewMenu"

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
	popup_manager.jump_start()
	editor_manager.jump_start()
	raw_manager.jump_start()
	
	popup_manager.register_popup("file", file_menu.get_popup())
	popup_manager.register_popup("view", view_menu.get_popup())
	
	var filePop = popup_manager.get_popup_data("file")
	filePop.register_entity(my_id, self, "handle_file_menu")
	filePop.add_option(my_id, openOption)
	filePop.add_option(my_id, openFileOption)
	filePop.add_separator(my_id)
	filePop.add_option(my_id, saveOption)
	filePop.add_option(my_id, saveAsOption)
	filePop.add_separator(my_id)
	filePop.add_option(my_id, exportOption)
	filePop.add_separator(my_id)
	filePop.add_option(my_id, prefsOption)
	
	var viewPop = popup_manager.get_popup_data("view")
	viewPop.register_entity(my_id, self, "handle_view_menu")
	viewPop.add_option(my_id, creatorOption)
	viewPop.add_separator(my_id)
	viewPop.add_option(my_id, spidOption)
	viewPop.add_separator(my_id)
	viewPop.add_option(my_id, vid1Option)
	viewPop.add_option(my_id, vid2Option)
	
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
	var interp = activeInterpreter.raw_to_interp(Session.data.raw)
	Session.data.interp = interp
	repaint_editors()
	pass

func handle_file_menu(selected):
	
	pass

func handle_edit_menu(selected):
	pass

func handle_view_menu(selected):
	match selected:
		creatorOption:
			Functions.open_link("https://arcturusforge.itch.io/")
			console_manager.generate("Opening link to the app creator's page...", Globals.green)
		spidOption:
			Functions.open_link("https://www.nexusmods.com/skyrimspecialedition/mods/36869")
			console_manager.generate("Opening link to SPID's mod page...", Globals.green)
		vid1Option:
			Functions.open_link("https://youtu.be/JGJfZb6Mj5o")
			console_manager.generate("Opening link to video guide 1...", Globals.green)
		vid2Option:
			Functions.open_link("https://youtu.be/pbON1N0U_44")
			console_manager.generate("Opening link to video guide 2...", Globals.green)
	pass
