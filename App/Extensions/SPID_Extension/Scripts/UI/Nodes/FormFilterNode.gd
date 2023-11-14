extends HBoxContainer

#-- Scene Refs
onready var id_panel = $VBoxContainer/IdPanel
onready var delete_button = $DeleteButton

#-- Dynamic Vars
var filter
var index

func assign(filter, index):
	self.filter = filter
	self.index = index
	

func set_value(value:String):
	id_panel.put(value)
	

func get_value():
	return id_panel.grab()
	

func removed_index(removedIndex:int):
	if removedIndex < index:
		index -= 1
	pass

func _on_DeleteButton_pressed():
	filter.remove_node(index)
	pass
