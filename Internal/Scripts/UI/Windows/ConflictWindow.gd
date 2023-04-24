extends Control

#-- Assigned by system
var window_manager
var hasHistory:bool

#-- Managers
var overallManager

#-- Scene Refs
onready var tree = $VBoxContainer/Tree
onready var confirm_button = $VBoxContainer/HBoxContainer/ConfirmButton
#-- Prefabs
#-- Dynamic Vars
var selected = ""

#--- Called when the window is added to the scene.
func _create():
	overallManager = Globals.get_manager("overall")
	pass

#--- Called when the window is activated.
func _enable(_data):
	confirm_button.disabled = true
	tree.clear()
	var root = tree.create_item()
	for extPath in _data:
		var node = tree.create_item(root)
		node.set_text(0, " " + extPath.get_file())
		node.set_metadata(0, extPath)
	pass

#--- Called when the window is deactivated.
func _disable():
	print("fsdfsd")
	pass

func _on_Tree_item_selected():
	var node = tree.get_selected()
	selected = node.get_metadata(0)
	confirm_button.disabled = false
	pass

func _on_Tree_item_activated():
	_on_ConfirmButton_pressed()
	pass 

func _on_ConfirmButton_pressed():
	window_manager.disable_window()
	overallManager.resolved_conflict(selected)
	pass

func _on_CancelButton_pressed():
	Globals.get_manager("console").posterr("Failed to select a compatible extenison...")
	window_manager.disable_window()
	pass
