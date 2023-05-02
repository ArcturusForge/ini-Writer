extends Node

var config = {
	"versionId"             : "1.0.3",
	"appName"               : "ini Writer",
	"sessionNameDefault"    : "Untitled_Session",
	"saveExtension"         : "ini"
}

#-- Paths
var resDataPath = "res://App/"
var userDataPath = "user://"
var extenDir = "Extensions"
var localExtenPath = resDataPath+"Extensions"
var userExtenPath = userDataPath+"Extensions"

#-- Color Hexes
var clear = "#00000000"
var grey = "#b2b5bb"
var red = "#a25062"
var yellow = "#b7ab7c"
var blue = "#6182b6"
var green = "#a5efac"

#-- Globalizer
var managers = {}

func _ready():
	#- Makes sure the additional folder exists.
	Functions.ensure_directory(localExtenPath)
#	Functions.ensure_directory(userExtenPath)
	OS.set_window_title(config.appName + " " + config.versionId)
	pass

#--- Repaints the app's name to indicate whether save worthy changes have been made to the session
func repaint_app_name(needsSaving:bool = false):
	if not needsSaving:
		OS.set_window_title(config.appName + " " + config.versionId + " - " + Session.sessionName)
	else:
		OS.set_window_title(config.appName + " " + config.versionId + " - " + Session.sessionName + " (*)")
	pass

func set_manager(name:String, manager):
	if managers.has(name):
		printerr("Overwriting an existing manager")
		return
	managers[name] = manager

func get_manager(name:String):
	if managers.has(name):
		return managers[name]
	return null
