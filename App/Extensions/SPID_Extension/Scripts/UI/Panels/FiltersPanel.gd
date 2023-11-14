extends PanelContainer

export(NodePath) var filter_container_path
onready var filter_container = get_node(filter_container_path)
export(PackedScene) var filter_prefab

func put(filterLine:String)->void:
	if filterLine == "NONE" || filterLine == "":
			return
	
	for filterData in filterLine.split(",", false):
		var filter = filter_prefab.instance()
		filter_container.add_child(filter)
		filter.add_existing(filterData)
	

func grab()->String:
	var line:String
	if filter_container.get_child_count() > 0:
		for i in range(filter_container.get_child_count()):
			var filter = filter_container.get_child(i)
			line += filter.compile_data()
			if i != filter_container.get_child_count() - 1:
				line += ","
	else:
		line = "NONE"
	return line
	

func _on_AddButton_pressed():
	var filter = filter_prefab.instance()
	filter_container.add_child(filter)
	filter.add_node()
	
