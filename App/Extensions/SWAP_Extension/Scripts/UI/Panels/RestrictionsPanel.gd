extends PanelContainer

#-- Scene Refs
onready var v_box_container = $VBoxContainer/VBoxContainer

#-- Prefabs
var restriction_node = "res://App/Extensions/SWAP_Extension/Interfaces/Nodes/RestrictionNode.tscn"

func set_data(edit):
	for restr in edit.restrictions:
		var node = Functions.get_from_prefab(restriction_node)
		v_box_container.add_child(node)
		node.set_value(restr)
	pass

func get_data():
	var results = []
	for node in v_box_container.get_children():
		results.append(node.get_value())
	return results

func _on_AddButton_pressed():
	var node = Functions.get_from_prefab(restriction_node)
	v_box_container.add_child(node)
	pass
