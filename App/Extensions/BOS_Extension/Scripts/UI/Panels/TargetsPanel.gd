extends PanelContainer

#-- Scene Refs
onready var v_box_container = $VBoxContainer/VBoxContainer
onready var replacement_node = $VBoxContainer/VBoxContainer/ReplacementNode


#-- Prefabs
var replacement_prefab = "res://App/Extensions/BOS_Extension/Interfaces/Nodes/ReplacementNode.tscn"

func set_data(edit):
	for i in range(edit.replacements.size()):
		if i == 0:
			replacement_node.set_value(edit.replacements[i])
		else:
			var node = Functions.get_from_prefab(replacement_prefab)
			v_box_container.add_child(node)
			node.set_value(edit.replacements[i])
	pass

func get_data():
	var results = []
	for child in v_box_container.get_children():
		results.append(child.get_value())
	return results

func _on_AddButton_pressed():
	var node = Functions.get_from_prefab(replacement_prefab)
	v_box_container.add_child(node)
	pass
