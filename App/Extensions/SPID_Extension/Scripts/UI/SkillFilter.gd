extends PanelContainer

#-- Scene Refs
onready var add_req_button:Button = $VBoxContainer/AddReqButton
onready var node_container:VBoxContainer = $VBoxContainer/SkillFilterContainer
onready var modifier_selector:OptionButton = $VBoxContainer/SkillModifierSelect

#-- Prefabs
var filter_node_prefab = "res://App/Extensions/SPID_Extension/Interfaces/Nodes/SkillFilterNode.tscn"

#-- Graphics
onready var locked_range = preload("res://Internal/Default/Icons/lock_closed.png")
onready var unlocked_range = preload("res://Internal/Default/Icons/lock_open.png")

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
	node.assign(self, index, locked_range, unlocked_range)
	pass

func add_existing(filter:String):
	#- Create a node
	add_node()
	var node = nodes[nodes.size()-1]
	
	if "-" in filter: #- Exclude
		modifier_selector.select(1)
		handle_modifier(1)
		filter = filter.replace("-", "")
		var vals = filter.split("(", false)
		vals[1] = vals[1].replace(")", "")
		var rangeVals
		if "/" in vals[1]:
			rangeVals = vals[1].split("/", false)
		else:
			rangeVals = [vals[1], -1]
		node.set_value("w" in vals[0], int(vals[0]), int(rangeVals[0]), int(rangeVals[1]))
	elif "+" in filter: #- Linked
		modifier_selector.select(2)
		handle_modifier(2)
		var ids = filter.split("+", false)
		var vals1 = ids[0].split("(", false)
		vals1[1] = vals1[1].replace(")", "")
		var rangeVals1
		if "/" in vals1[1]:
			rangeVals1 = vals1[1].split("/", false)
		else:
			rangeVals1 = [vals1[1], -1]
		node.set_value("w" in vals1[0], int(vals1[0]), int(rangeVals1[0]), int(rangeVals1[1]))
		for i in ids.size():
			if i == 0:
				continue
			if i > 1: #- HandleModifier() creates the second node.
				add_node()
			node = nodes[nodes.size()-1]
			var vals2 = ids[i].split("(", false)
			vals2[1] = vals2[1].replace(")", "")
			var rangeVals2
			if "/" in vals2[1]:
				rangeVals2 = vals2[1].split("/", false)
			else:
				rangeVals2 = [vals2[1], -1]
			node.set_value("w" in vals2[0], int(vals2[0]), int(rangeVals2[0]), int(rangeVals2[1]))
	else: #- Standard
		modifier_selector.select(0)
		handle_modifier(0)
		var vals = filter.split("(", false)
		vals[1] = vals[1].replace(")", "")
		var rangeVals
		if "/" in vals[1]:
			rangeVals = vals[1].split("/", false)
		else:
			rangeVals = [vals[1], -1]
		node.set_value("w" in vals[0], int(vals[0]), int(rangeVals[0]), int(rangeVals[1]))
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
	return filter
