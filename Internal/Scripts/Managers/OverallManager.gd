extends Control

#-- Constants
const my_id = "main"

#-- Managers
onready var search_manager = $"../SearchManager"
onready var window_manager = $"../WindowManager"
onready var raw_manager = $"../RawManager"
onready var editor_manager = $"../EditorManager"
onready var color_manager = $"../ColorManager"
onready var console_manager = $"../ConsoleManager"

func _ready():
	Globals.set_manager(my_id, self)
	search_manager.jump_start()
	console_manager.jump_start()
	pass
