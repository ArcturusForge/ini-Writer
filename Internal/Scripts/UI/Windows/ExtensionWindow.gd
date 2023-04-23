extends Control

#-- Assigned by system
var window_manager
var hasHistory:bool

#-- Managers
var overallManager

#-- Scene Refs
onready var tree = $VBoxContainer/ScrollContainer/Tree
#-- Prefabs
#-- Dynamic Vars

#--- Called when the window is added to the scene.
func _create():
	overallManager = Globals.get_manager("overall")
	pass

#--- Called when the window is activated.
func _enable(_data):
	
	pass

#--- Called when the window is deactivated.
func _disable():
	pass


func _on_ConfirmButton_pressed():
	pass # Replace with function body.


func _on_CancelButton_pressed():
	if hasHistory:
		window_manager.activate_previous()
	pass 
