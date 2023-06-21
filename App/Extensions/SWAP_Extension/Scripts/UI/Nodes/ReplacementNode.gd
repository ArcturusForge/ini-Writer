extends PanelContainer

#-- Scene Refs
onready var source_select = $VBoxContainer/HBoxContainer/VBoxContainer/SourceSelect
onready var id_edit = $VBoxContainer/HBoxContainer/VBoxContainer/IdEdit
onready var source_edit = $VBoxContainer/HBoxContainer/VBoxContainer/SourceContainer/SourceEdit
onready var clean_check_box = $VBoxContainer/HBoxContainer/VBoxContainer/CleanCheckBox
onready var source_container = $VBoxContainer/HBoxContainer/VBoxContainer/SourceContainer

func _ready():
	handle_selected(0)
	source_select.connect("item_selected", self, "handle_selected")
	pass

func handle_selected(index:int):
	match index:
		0:
			clean_check_box.visible = false
			source_container.visible = false
		1,2:
			clean_check_box.visible = true
			source_container.visible = true
	pass

func set_value(data:String):
	if "~" in data:
		id_edit.text = data.get_slice("~", 0)
		source_edit.text = data.get_slice("~", 1)
		if "esl" in data:
			source_select.selected = 2
		else:
			source_select.selected = 1
	else:
		source_select.selected = 0
		id_edit.text = data
	handle_selected(source_select.selected)
	pass

func get_value():
	var value = ""
	match source_select.selected:
		0: #- (EditorID)
			value = id_edit.text
		1,2: #- (Esm/Esp) (Esl)
			if clean_check_box.pressed:
				var t = id_edit.text
				t.erase(0, 2)
				while t[0] == 0:
					t.erase(0, 1)
				value = "0x" + t
			else:
				value = id_edit.text
			value += "~" + source_edit.text
	return value

func _on_DeleteButton_pressed():
	queue_free()
	pass
