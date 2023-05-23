extends PanelContainer

#-- Scene Refs
onready var source_select:OptionButton = $VBoxContainer/SourceSelect
onready var id_edit:LineEdit = $VBoxContainer/IdEdit
onready var source_container = $VBoxContainer/SourceContainer
onready var source_edit:LineEdit = $VBoxContainer/SourceContainer/SourceEdit
onready var check_box = $VBoxContainer/HBoxContainer/CheckBox
onready var cleaning_container = $VBoxContainer/HBoxContainer

func _ready():
	source_select.connect("item_selected", self, "handle_source")
	pass

#--- Used to init the ui.
func set_data(edit):
	#- Adjust selector
	source_select.selected = edit.objectId.type
	handle_source(edit.objectId.type)
	id_edit.text = edit.objectId.value
	source_edit.text = edit.objectId.source
	pass

#--- Used to compile the data into an edit.
#--- [edit] is a instance reference so changes will apply for all ref holders.
func apply_data(edit):
	var val = id_edit.text
	
	#- Automatic Cleaning Functionality
	if check_box.pressed: 
		#- Remove leading zeroes.
		var id = id_edit.text.get_slice("~", 0)
		var number = ""
		if "0x" in id: #- Split off 0x first
			number = id.get_slice("x", 1)
		else: #- May look like FE003245
			var temp:String = id
			temp.erase(0, 3)
			number = temp
		
		while number[0] == '0':
				number.erase(0, 1)
		
		val = "0x" + number
		if "~" in id_edit.text:
			val += "~" + id_edit.text.get_slice("~", 1)
		edit.objectId.value = val
	else:
		edit.objectId.value = id_edit.text
	
	edit.objectId.type = source_select.selected
	edit.objectId.source = source_edit.text
	pass

func handle_source(selected):
	match selected:
		0:#- EditorID
			source_container.visible = false
			cleaning_container.visible = false
			check_box.pressed = false
		1,2,3:#- Esm/Esp/Skyrim & dlc
			source_container.visible = true
			cleaning_container.visible = true
	pass
