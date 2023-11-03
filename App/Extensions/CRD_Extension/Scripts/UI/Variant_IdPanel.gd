extends VBoxContainer

#-- Scene Vars
onready var selector:OptionButton = $SourceSelect
onready var autoClean:CheckBox = $CheckBox
onready var idInput:LineEdit = $IdEdit
onready var sourceContainer:VBoxContainer = $SourceContainer
onready var sourceInput:LineEdit = $SourceContainer/SourceEdit

func put(line:String)->void:
	autoClean.visible = true
	sourceContainer.visible = true
	
	if not "esm" in line && not "esp" in line && not "esl" in line:
		return
	
	var data = line.split("~")
	idInput.text = data[0]
	sourceInput.text = data[1]
	

func grab()->String:
	var t = ""
	if !autoClean.pressed:
		t = idInput.text + "~" + sourceInput.text
	else:
		var id = idInput.text
		if "esl" in sourceInput.text:
			id.erase(0, 5)
		elif "esm" in sourceInput.text || "esp" in sourceInput.text:
			id.erase(0, 2)
		while id[0] == "0":
			id.erase(0, 1)
		t = "0x" + id + "~" + sourceInput.text
	return t
	

