extends Control

#-- Assigned by system
var window_manager
var hasHistory:bool

#-- Managers
var overallManager

#-- Scene Refs
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

func _on_Button2_pressed():
	Globals.get_manager("search").search_for_session(self, "found_session")
	pass

func found_session(path:String):
	window_manager.disable_window()
	overallManager.load_session(path)
	pass

func _on_Button_pressed():
	window_manager.activate_window("extension")
	pass
