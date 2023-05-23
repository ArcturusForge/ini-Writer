extends HBoxContainer

#-- Scene Refs
onready var string_edit = $VBoxContainer/StringEdit
onready var delete_button = $DeleteButton
onready var check_box = $VBoxContainer/HBoxContainer/CheckBox

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
	var val = string_edit.text
	if check_box.pressed:
		#- Remove leading zeroes.
		var id = string_edit.text.get_slice("~", 0)
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
		if "~" in string_edit.text:
			val += "~" + string_edit.text.get_slice("~", 1)
	return val

func removed_index(removedIndex:int):
	if removedIndex < index:
		index -= 1
	pass

func _on_DeleteButton_pressed():
	filter.remove_node(index)
	pass
