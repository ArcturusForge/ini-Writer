extends Control

onready var label_2 = $EditPanel/VBoxContainer/IndexLabels/Label2

var filePath:String

func _ready():
	get_tree().connect("files_dropped", self, "load_from_drop")
	_import_complete()
	

func load_from_drop(filePaths:PoolStringArray, _screen:int)->void:
	var path :String = filePaths[0]
	if path.ends_with(".zip"):
		filePath = path
		label_2.text = filePath.get_file()
		self.show()
	elif path.ends_with(".ini"):
		Console.postconf("Attempting to import ini file...")
		Globals.get_manager("window").disable_window()
		Globals.get_manager("overall").load_session(path)
		self.hide()
	

func _on_ExtButton_pressed()->void:
	Console.postconf("Attempting to import writer extension...")
	ZipImporter.import_extension_zip(filePath)
	_import_complete()
	

func _on_ResButton_pressed()->void:
	Console.postconf("Attempting to import writer resources...")
	ZipImporter.import_resource_zip(filePath)
	_import_complete()
	

func _import_complete()->void:
	filePath = ""
	label_2.text = ""
	self.hide()
	

func _on_CancelButton_pressed():
	_import_complete()
	
