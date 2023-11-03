extends VBoxContainer

#-- Scene Vars
onready var selector:OptionButton = $SourceSelect
onready var autoClean:CheckBox = $CheckBox
onready var idInput:LineEdit = $IdEdit
onready var sourceContainer:VBoxContainer = $SourceContainer
onready var sourceInput:LineEdit = $SourceContainer/SourceEdit

func put(line:String)->void:
	if "esm" in line || "esp" in line || "esl" in line:
		selector.select(1)
		_on_SourceSelect_item_selected(1)
		var data = line.split("~")
		idInput.text = data[0]
		sourceInput.text = data[1]
	else:
		_on_SourceSelect_item_selected(0)
		idInput.text = line
	

func grab()->String:
	var t = ""
	if selector.selected == 0:
		t = idInput.text
	elif selector.selected == 1:
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
	

func _on_SourceSelect_item_selected(index):
	match index:
		0:
			autoClean.visible = false
			sourceContainer.visible = false
		1:
			autoClean.visible = true
			sourceContainer.visible = true
	
