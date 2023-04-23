extends Control

#-- Assigned by system
var window_manager

#-- Managers
var mainManager

#-- Scene Refs
#-- Prefabs
#-- Dynamic Vars

#--- Called when the window is added to the scene.
func _create():
	mainManager = Globals.get_manager("main")
	pass

#--- Called when the window is activated.
func _enable(_data):
	
	pass

#--- Called when the window is deactivated.
func _disable():
	pass
