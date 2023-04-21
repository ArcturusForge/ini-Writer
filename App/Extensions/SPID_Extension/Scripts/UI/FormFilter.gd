extends PanelContainer

#-- Scene Refs
onready var add_req_button:Button = $HBoxContainer/AddReqButton
onready var node_container:VBoxContainer = $HBoxContainer/NodeContainer
onready var modifier_selector:OptionButton = $HBoxContainer/VBoxContainer2/ModifierSelector

#-- Prefabs
var filter_node_prefab = "res://App/Extensions/SPID_Extension/Interfaces/Nodes/FormFilterNode.tscn"

#-- Dynamic Vars
var nodes = []

func _ready():
	#add_node()
	modifier_selector.connect("item_selected", self, "handle_modifier")
	handle_modifier(0)
	pass

func handle_modifier(index):
	match index:
		0,1:#- (0)Standard, (1)Exclude
			add_req_button.visible = false
			#- Remove additional entries.
			for i in range(nodes.size()-1, -1, -1):
				if i == 0:
					continue
				nodes[i]._on_DeleteButton_pressed()
		2:#- Linked
			add_req_button.visible = true
			add_node()
	pass

func add_node():
	var node = load(filter_node_prefab).instance()
	var index = nodes.size()
	node_container.add_child(node)
	nodes.append(node)
	node.assign(self, index)
	pass

func add_existing(filter:String):
	#- Create a node
	add_node()
	var node = nodes[nodes.size()-1]
	
	if "-" in filter: #- Exclude
		modifier_selector.select(1)
		handle_modifier(1)
		node.set_value(filter.replace("-", ""))
	elif "+" in filter: #- Linked
		modifier_selector.select(2)
		handle_modifier(2)
		var ids = filter.split("+", false)
		node.set_value(ids[0])
		for i in ids.size():
			if i == 0:
				continue
			if i > 1: #- HandleModifier() creates the second node.
				add_node()
			node = nodes[nodes.size()-1]
			node.set_value(ids[i])
	else: #- Standard
		modifier_selector.select(0)
		handle_modifier(0)
		node.set_value(filter)
	pass

func remove_node(index):
	if nodes.size() == 1:
		#- Delete the entire filter.
		self.queue_free()
		pass
	elif nodes.size() == 2:
		#- Return modifer to standard
		var node = nodes[index]
		nodes.remove(index)
		node.queue_free()
		modifier_selector.select(0)
		handle_modifier(0)
	else:
		#- Just delete the node.
		var node = nodes[index]
		nodes.remove(index)
		node.queue_free()
		for other in nodes:
			other.removed_index(index)
	pass

func _on_AddReqButton_pressed():
	add_node()
	pass

func compile_data():
	var filter = ""
	match modifier_selector.selected:
		0:#- (0)Standard
			filter = nodes[0].get_value()
		1:#- (1)Exclude
			filter = "-" + nodes[0].get_value()
		2:#- (2)Linked
			for i in range(nodes.size()):
				filter += nodes[i].get_value()
				if i < nodes.size() - 1:
					filter += "+"
	
	#- Automatic shortening feature.
	if "{" in filter:
		var start = filter.find("{")
		var end = filter.find("}")
		var length = end - start + 1
		var uncleanID = filter.substr(start, length)
		var pluginType = -1
		if "~" in uncleanID:
			if "esm" in uncleanID || "esp" in uncleanID:
				pluginType = 0
			else:
				pluginType = 1
		match pluginType:
			-1:#- Skyrim or original dlc
				uncleanID = uncleanID.replace("{", "").replace("}", "")
				var cleanID = shorten_id(uncleanID, 6)
				filter = filter.replace("{" + uncleanID + "}", cleanID)
				pass
			0:#- esm or esp
				uncleanID = uncleanID.replace("{", "").replace("}", "")
				var idAndSource = uncleanID.split("~")
				var cleanID = shorten_id(idAndSource[0], 6)
				filter = filter.replace("{" + uncleanID + "}", cleanID + "~" + idAndSource[1])
				pass
			1:#- esl
				uncleanID = uncleanID.replace("{", "").replace("}", "")
				var idAndSource = uncleanID.split("~")
				var cleanID = shorten_id(idAndSource[0], 3)
				filter = filter.replace("{" + uncleanID + "}", cleanID + "~" + idAndSource[1])
				pass
	return filter

func shorten_id(uncleanID:String, charCap:int):
	var cleanID = uncleanID
	if "0x" in cleanID:
		cleanID = cleanID.replace("0x", "")
	
	while cleanID.length() > charCap:
		cleanID.erase(0, 1)
	
	while not cleanID == "" && cleanID[0] == "0":
		cleanID.erase(0, 1)
	
	cleanID = "0x" + cleanID
	return cleanID
