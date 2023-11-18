extends Node

var config = {
	"versionId"             : "2.0.0",
	"appName"               : "ini Writer",
	"sessionNameDefault"    : "Untitled_Session",
	"saveExtension"         : "ini"
}

#-- Paths
var resDataPath = "res://App/"
var userDataPath = "user://"
var extenDir = "Extensions"
var localExtenPath = resDataPath+"Extensions"
var localResouPath = resDataPath+"Resources"
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
	var extenName := ""
	if managers.has("overall") && managers["overall"].extension.config.has("extension"):
		var conf = managers["overall"].extension.config
		extenName = " - " + conf.game + "(" + conf.extension + ") "
	
	if not needsSaving:
		OS.set_window_title(config.appName + " " + config.versionId + " - " + Session.sessionName + extenName)
	else:
		OS.set_window_title(config.appName + " " + config.versionId + " - " + Session.sessionName + extenName + " (*)")
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

func Version_Check(requestedVersion:String)->bool:
	var actVer = config.versionId.split(".")
	var reqVer = requestedVersion.split(".")
	if int(actVer[0]) <= int(reqVer[0]):
		if int(actVer[1]) <= int(reqVer[1]):
			if int(actVer[2]) < int(reqVer[2]):
				managers["console"].postwrn("Older version of ini Writer detected! Download the new update!")
				managers["console"].posterr("Choosing to continue may break this extension!")
				return false
	return true
	
