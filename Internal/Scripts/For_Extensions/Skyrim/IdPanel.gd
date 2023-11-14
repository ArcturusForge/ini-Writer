extends VBoxContainer

export var useSelector:=true
export var selectorBypassedDefault:=0

#-- Scene Vars
onready var selector_container:VBoxContainer = $SelectorContainer
onready var selector:OptionButton = $SelectorContainer/SourceSelect
onready var formContainer:VBoxContainer = $FormUI
onready var autoClean:CheckBox = $FormUI/CleaningContainer/ShortenCheckBox
onready var isEspfe:CheckBox = $FormUI/CleaningContainer/EspfeCheckBox
onready var editorContainer:HBoxContainer = $EditorUI
onready var idInput:LineEdit = $IdEdit
onready var sourceContainer:VBoxContainer = $SourceContainer
onready var sourceInput:LineEdit = $SourceContainer/SourceEdit

func _ready():
	_on_ShortenCheckBox_toggled(false)
	_selector_check()
	

func put(line:String)->void:
	if "esm" in line || "esp" in line || "esl" in line || "0x" in line:
		if useSelector:
			selector.select(0)
			_on_SourceSelect_item_selected(0)
		if "~" in line:
			var data = line.split("~")
			idInput.text = data[0]
			sourceInput.text = data[1]
		else:
			idInput.text = line
	else:
		if useSelector:
			selector.select(1)
			_on_SourceSelect_item_selected(1)
		idInput.text = line
	

func grab()->String:
	var t = ""
	if (selector.selected == 1 && useSelector) || selectorBypassedDefault == 1:
		t = idInput.text
	elif (selector.selected == 0 && useSelector) || selectorBypassedDefault == 0:
		if !autoClean.pressed:
			t = idInput.text
		else:
			var id := idInput.text
			if "esl" in sourceInput.text || ("esp" in sourceInput.text && isEspfe.pressed) || ("esp" in sourceInput.text && id.begins_with("FE")):
				id.erase(0, 5)
			else:
				id.erase(0, 2)
			while id[0] == "0":
				id.erase(0, 1)
			t = "0x" + id 
		
		if sourceInput.text != "":
				t += "~" + sourceInput.text
	return t
	

func _selector_check()->void:
	if !useSelector:
		selector_container.visible = false
		_on_SourceSelect_item_selected(selectorBypassedDefault)
	else:
		_on_SourceSelect_item_selected(0)
	

func _on_SourceSelect_item_selected(index):
	match index:
		0:
			formContainer.visible = true
			sourceContainer.visible = true
			editorContainer.visible = false
			idInput.placeholder_text = "e.g. FE051801"
		1:
			formContainer.visible = false
			sourceContainer.visible = false
			editorContainer.visible = true
			idInput.placeholder_text = "e.g. Elisif the Fair"
	

func _on_ShortenCheckBox_toggled(button_pressed):
	isEspfe.disabled = !button_pressed
	if !button_pressed:
		isEspfe.pressed = false
	
