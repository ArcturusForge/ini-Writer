extends PanelContainer

#-- Scene Refs
onready var name_edit = $VBoxContainer/NameContainer/NameEdit
onready var comment_edit = $VBoxContainer/CommentEdit

#-- Prefabs


func set_data(edit):
	name_edit.text = edit.notation.name
	comment_edit.text = edit.notation.comment
	pass

func get_data():
	var results = [
		name_edit.text,
		comment_edit.text
	]
	return results
