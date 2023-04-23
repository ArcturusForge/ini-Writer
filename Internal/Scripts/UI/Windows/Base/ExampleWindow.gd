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
