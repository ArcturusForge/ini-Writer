extends PanelContainer

onready var name_container = $VBoxContainer/NameContainer
onready var name_edit = $VBoxContainer/NameContainer/NameEdit
onready var comment_edit = $VBoxContainer/CommentEdit
onready var newlines_box = $VBoxContainer/SpinBox

func setup(comment:String, newlines:int, useName:bool, name:="")->void:
	comment_edit.text = comment
	newlines_box.value = newlines
	if useName:
		toggle_name(true)
		name_edit.text = name
	else:
		toggle_name(false)
		name_edit.text = ""
	

func grab()->Dictionary:
	return {
		"name":name_edit.text,
		"comment":comment_edit.text,
		"newlines":int(newlines_box.value)
	}

func toggle_name(isVisible:bool)->void:
	name_container.visible = isVisible
	
