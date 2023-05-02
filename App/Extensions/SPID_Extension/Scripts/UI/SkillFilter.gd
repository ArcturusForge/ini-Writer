extends PanelContainer

#-- Scene Refs
onready var skill_filter_node = $VBoxContainer/SkillFilterNode

#-- Graphics
onready var locked_range = preload("res://Internal/Default/Icons/lock_closed.png")
onready var unlocked_range = preload("res://Internal/Default/Icons/lock_open.png")

func _ready():
	skill_filter_node.assign(self, 0, locked_range, unlocked_range)
	pass

func add_existing(filter:String):
	var vals = filter.split("(", false)
	vals[1] = vals[1].replace(")", "")
	var rangeVals
	if "/" in vals[1]:
		rangeVals = vals[1].split("/", false)
	else:
		rangeVals = [vals[1], -1]
	skill_filter_node.set_value("w" in vals[0] || "W" in vals[0], int(vals[0]), int(rangeVals[0]), int(rangeVals[1]))
	pass

func remove_node(index):
	self.queue_free()
	pass

func compile_data():
	return skill_filter_node.get_value()
