extends HBoxContainer

#-- Scene Refs
onready var string_edit = $VBoxContainer/StringEdit
onready var delete_button = $DeleteButton
onready var linked_modifer_parent = $VBoxContainer/LinkedModifer
onready var option_button = $VBoxContainer/LinkedModifer/OptionButton

#-- Dynamic Vars
var filter
var index

func assign(filter, index):
	self.filter = filter
	self.index = index
	pass

func toggle_linked_field(visible:bool)->void:
	linked_modifer_parent.visible = visible
	

func set_value(value:String, isLinked:=false):
	if isLinked:
		linked_modifer_parent.visible = true
		if value[0] == "*":
			option_button.select(1)
			value.erase(0, 1)
	else:
		linked_modifer_parent.visible = false
	string_edit.text = value
	pass

func get_value():
	var t = ""
	if linked_modifer_parent.visible == true && option_button.selected == 1:
		t+= "*"
	t+= string_edit.text
	return t

func removed_index(removedIndex:int):
	if removedIndex < index:
		index -= 1
	pass

func _on_DeleteButton_pressed():
	filter.remove_node(index)
	pass
