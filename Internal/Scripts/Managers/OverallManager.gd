extends Control

#-- Constants
const my_id = "overall"

#-- FileMenu Constants
const openOption = "Open ini"
const newOption = "New ini"
const openFileOption = "Open Save Location"
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
onready var opening_window = $"../../Windows/OpeningWindow"
onready var extension_window = $"../../Windows/ExtensionWindow"
onready var conflict_window = $"../../Windows/ConflictWindow"

#-- Dynamic Vars
var extension = {
	"path":"",
	"config":{},
	"interpreter":"",
	"editor":""
}
var activeInterpreter

func _ready():
	Globals.set_manager(my_id, self)
	search_manager.jump_start()
	console_manager.jump_start()
	popup_manager.jump_start()
	editor_manager.jump_start()
	raw_manager.jump_start()
	window_manager.jump_start()
	
	window_manager.register_window("open", opening_window, true)
	window_manager.register_window("extension", extension_window)
	window_manager.register_window("conflict", conflict_window)
	
	popup_manager.register_popup("file", file_menu.get_popup())
	popup_manager.register_popup("view", view_menu.get_popup())
	
	var filePop = popup_manager.get_popup_data("file")
	filePop.register_entity(my_id, self, "handle_file_menu")
	filePop.add_option(my_id, openOption, KEY_O)
	filePop.add_option(my_id, newOption, KEY_N)
	filePop.add_separator(my_id)
	filePop.add_option(my_id, saveOption, KEY_S)
	filePop.add_option(my_id, saveAsOption, KEY_S, true)
	filePop.add_separator(my_id)
	filePop.add_option(my_id, exportOption, KEY_E, true)
	filePop.add_separator(my_id)
	filePop.add_option(my_id, openFileOption)
	#filePop.add_option(my_id, prefsOption, KEY_P, true)
	
	var viewPop = popup_manager.get_popup_data("view")
	viewPop.register_entity(my_id, self, "handle_view_menu")
	viewPop.add_option(my_id, creatorOption)
	viewPop.add_separator(my_id)
	viewPop.add_option(my_id, spidOption)
	viewPop.add_separator(my_id)
	viewPop.add_option(my_id, vid1Option)
	viewPop.add_option(my_id, vid2Option)
	pass

func reset():
	extension = {
		"path":"",
		"config":{},
		"interpreter":"",
		"editor":""
	}
	activeInterpreter = null
	Session.reset_data()
	repaint_editors()
	pass

func load_session(path:String):
	reset()
	Session.load_data(path)
	
	var compatibleExtensions = []
	var extensions = Functions.get_all_files(Globals.localExtenPath, "json")
	for configPath in extensions:
		var extfile = File.new()
		if extfile.open(configPath, File.READ) > 0:
			print ("Unable to load: " + configPath)
			console_manager.posterr("Unable to load: " + configPath)
			continue
		var extensionDir = configPath.get_base_dir()
		var config = parse_json(extfile.get_as_text())
		var interpreter = load(extensionDir +"/"+ config.interpreterScript).new()
		extfile.close()
		if interpreter.data_matched(Session.data.raw, Session.sessionName):
			compatibleExtensions.append(configPath)
	
	if compatibleExtensions.size() == 0:
		console_manager.posterr("No compatible extension detected for file: " + path.get_file())
	elif compatibleExtensions.size() == 1:
		resolved_conflict(compatibleExtensions[0])
	else:
		window_manager.activate_window("conflict", compatibleExtensions)
	pass

func resolved_conflict(extensionPath:String):
	load_extension(extensionPath)
	Session.data.interp = activeInterpreter.raw_to_interp(Session.data.raw)
	repaint_editors()
	console_manager.generate("Loaded ini: " + Session.sessionName, Globals.green)
	Globals.repaint_app_name()
	pass

func new_session(extensionPath:String):
	reset()
	load_extension(extensionPath)
	Globals.repaint_app_name()
	pass

func load_extension(path:String):
	var file = File.new()
	var err = file.open(path, File.READ)
	if err > 0:
		print ("Unable to load extension:" + path)
		console_manager.posterr("Unable to load extension:" + path)
		return
	extension.path = path.get_base_dir()
	extension.config = parse_json(file.get_as_text())
	file.close()
	extension.interpreter = extension.path +"/"+ extension.config.interpreterScript
	extension.editor = extension.path +"/"+ extension.config.editorInterface
	activeInterpreter = load(extension.interpreter).new()
	Session.data.interp = activeInterpreter.init_interp()
	console_manager.generate("Activated extension: " + extension.config.extension + " " + extension.config.version, Globals.green)
	pass

#--- Regenerates both editors.
func repaint_editors():
	repaint_interp_editor()
	repaint_raw_editor()
	pass

#--- Regenerates the interp editor window.
func repaint_interp_editor():
	var nameArray = []
	if not activeInterpreter == null:
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
	match selected:
		openOption:
			search_manager.search_for_session(self, "load_session")
		newOption:
			window_manager.activate_window("extension")
		openFileOption:
			Functions.open_directory(Functions.os_path_convert(Session.savePath.get_base_dir()))
		saveOption:
			if not Session.has_saved():
				search_manager.search_to_save(self, "intercept_save")
			else:
				Session.quick_save()
				console_manager.generate("Saved: " + Session.sessionName, Globals.green)
				Globals.repaint_app_name()
		saveAsOption:
			search_manager.search_to_save(self, "intercept_save")
		exportOption:
			search_manager.search_to_save(self, "export_save")
		prefsOption:
			pass
	pass

func intercept_save(filePath:String):
	var name = activeInterpreter.alter_save_name(filePath.get_file().replace(".ini", ""))
	var fixedPath = filePath.replace(filePath.get_file(), name + ".ini")
	console_manager.generate("Saved ini: " + fixedPath, Globals.green)
	Session.save_data(fixedPath, true)
	Globals.repaint_app_name()
	pass

func export_save(filePath:String):
	var name = activeInterpreter.alter_save_name(filePath.get_file().replace(".ini", ""))
	var fixedPath = filePath.replace(filePath.get_file(), name + ".ini")
	console_manager.generate("Exported ini: " + fixedPath, Globals.green)
	Session.export_save(fixedPath)
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
