extends PanelContainer

#-- Scene Refs
onready var add_req_button:Button = $HBoxContainer/AddReqButton
onready var node_container:VBoxContainer = $HBoxContainer/NodeContainer
onready var modifier_selector:OptionButton = $HBoxContainer/VBoxContainer2/ModifierSelector

#-- Prefabs
var filter_node_prefab = "res://App/Local_Extensions/SPID_Extension/Interfaces/StringFilterNode.tscn"

#-- Dynamic Vars
var nodes = []

func _ready():
	add_node()
	modifier_selector.connect("item_selected", self, "handle_modifier")
	handle_modifier(0)
	pass

func handle_modifier(index):
	match index:
		0,1,2:#- (0)Standard, (1)Exclude, (2)Wildcard
			add_req_button.visible = false
			#- Remove additional entries.
			for i in range(nodes.size()):
				if i == 0:
					continue
				remove_node(i)
		3:#- Linked
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
	pass

func _on_AddReqButton_pressed():
	add_node()
	pass
