extends Control

#-- Assigned by system
var window_manager
var hasHistory:bool

#-- Managers
var overallManager

#-- Scene Refs
onready var tree = $VBoxContainer/ScrollContainer/Tree
onready var confirm_button = $VBoxContainer/HBoxContainer/ConfirmButton

#-- Dynamic Vars
var path = ""

#--- Called when the window is added to the scene.
func _create():
	overallManager = Globals.get_manager("overall")
	pass

#--- Called when the window is activated.
func _enable(_data):
	confirm_button.disabled = true
	var root = tree.create_item()
	var extensions = Functions.get_all_files(Globals.localExtenPath, "json")
	for exten in extensions:
		var node = tree.create_item(root)
		node.set_text(0, " " + exten.get_file())
		node.set_metadata(0, exten)
	pass

#--- Called when the window is deactivated.
func _disable():
	tree.clear()
	pass

func _on_CancelButton_pressed():
	if hasHistory:
		window_manager.activate_previous()
	else:
		window_manager.disable_window()
	pass 

func _on_ConfirmButton_pressed():
	confirmed_selected()
	pass

func _on_Tree_item_activated():
	confirmed_selected()
	pass

func _on_Tree_item_selected():
	confirm_button.disabled = false
	path = tree.get_selected().get_metadata(0)
	pass

func confirmed_selected():
	if path == "":
		return
	overallManager.new_session(path)
	window_manager.disable_window()
	pass
