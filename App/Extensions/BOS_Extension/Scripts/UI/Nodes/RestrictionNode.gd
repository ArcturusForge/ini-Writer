extends PanelContainer

#-- Scene Refs
onready var name_edit = $HBoxContainer/NodeContainer/NameEdit

func set_value(data:String):
	name_edit.text = data
	pass

func get_value():
	return name_edit.text

func _on_DeleteButton_pressed():
	self.queue_free()
	pass
