extends HBoxContainer

#-- Scene Refs
onready var string_edit = $VBoxContainer/StringEdit
onready var delete_button = $DeleteButton

#-- Dynamic Vars
var filter
var index

func assign(filter, index):
	self.filter = filter
	self.index = index
	pass

func set_value(value:String):
	string_edit.text = value
	pass

func get_value():
	return string_edit.text

func removed_index(removedIndex:int):
	if removedIndex < index:
		index -= 1
	pass

func _on_DeleteButton_pressed():
	filter.remove_node(index)
	pass
