extends PanelContainer

#-- Scene Refs
onready var source_select = $VBoxContainer/SourceSelect
onready var check_box = $VBoxContainer/CheckBox
onready var id_edit = $VBoxContainer/IdEdit
onready var source_edit = $VBoxContainer/SourceContainer/SourceEdit

#-- Prefabs

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
		Globals.get_manager("console").postwrn("Write cleaning function")
		pass
	else:
		var line = id_edit.text
		if not source_edit.text == "" && not source_select.selected == 0:
			line += "~" + source_edit.text
		results.append(line)
	return results
