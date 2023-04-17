extends Node

var sessionName: String
var data = {
		"raw":"",
		"interp":{}
	}

#-- Local Cache - Stored only during session and not saved.
var savePath := ""

#--- Erases any session data to default.
func reset_data():
	savePath = ""
	sessionName = Globals.config.sessionNameDefault
	data = {
		"raw":"",
		"interp":{}
	}
	pass

#--- Identifies if the current session has been saved before.
func has_saved():
	return true if not savePath == "" else false

func quick_save():
	save_data(savePath)
	pass

func get_copy_of_data():
	return data.duplicate(true)

#--- Makes a custom save but doesn't make it the active session.
func export_save(path:String, customData=self.data):
	if not Globals.config.saveExtension in sessionName:
		sessionName += "." + Globals.config.saveExtension
	
	write(path, customData)
	Globals.repaint_app_name()
	pass

#--- Makes a copy of the session and makes it the active session.
func save_data(path: String):
	if not Globals.config.saveExtension in sessionName:
		sessionName += "." + Globals.config.saveExtension
	
	if not sessionName in path:
		path += "/" + sessionName
	
	write(path, data)
	savePath = path
	Globals.repaint_app_name()
	pass

func write(path, cData):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_line(data.raw)
	file.close()
	pass

func load_data(path: String):
	var file = File.new()
	file.open(path, File.READ)
	var text = file.get_as_text()
	file.close()
	data.raw = text
	sessionName = path.get_file()
	savePath = path
	pass

#--- Loads the file but returns the data instead of caching it.
func import_load_data(path:String):
	var file = File.new()
	file.open(path, File.READ)
	var text = file.get_as_text()
	file.close()
	return text
