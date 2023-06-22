extends PanelContainer

#-- Scene Refs
onready var source_select = $VBoxContainer/SourceSelect
onready var check_box = $VBoxContainer/CheckBox
onready var id_edit = $VBoxContainer/IdEdit
onready var source_container = $VBoxContainer/SourceContainer
onready var source_edit = $VBoxContainer/SourceContainer/SourceEdit

#-- Prefabs

func _ready():
	handle_selected(0)
	source_select.connect("item_selected", self, "handle_selected")
	pass

func set_data(edit):
	var target = edit.target
	if "0x" in target && not ".esl" in target:
		source_select.select(1)
	elif "0x" in target && ".esl" in target:
		source_select.select(2)
	else:
		source_select.select(0)
	
	id_edit.text = target.get_slice("~", 0) if "~" in target else target
	source_edit.text = target.get_slice("~", 1) if "~" in target else ""
	pass

func get_data():
	var results = []
	if check_box.pressed:
		#- Clean id
		var id = id_edit.text
		id.erase(0, 2)
		while id[0] == "0":
			id.erase(0, 1)
		id = "0x" + id
		var line = id
		if not source_edit.text == "" && not source_select.selected == 0:
			line += "~" + source_edit.text
		results.append(line)
	else:
		var line = id_edit.text
		if not source_edit.text == "" && not source_select.selected == 0:
			line += "~" + source_edit.text
		results.append(line)
	return results

func handle_selected(index:int):
	match index:
		0:
			check_box.visible = false
			source_container.visible = false
		1,2:
			check_box.visible = true
			source_container.visible = true
	pass
