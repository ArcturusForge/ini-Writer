extends PanelContainer

#-- Scene Refs
onready var option_button = $VBoxContainer/OptionButton
onready var chance_container = $VBoxContainer/ChanceContainer
onready var spin_box = $VBoxContainer/ChanceContainer/SpinBox

#-- Prefabs

func _ready():
	handle_chance(0)
	option_button.connect("item_selected", self, "handle_chance")
	pass

func set_data(edit):
	
	pass

func get_data():
	var results = []
	
	return results

func handle_chance(index):
	match index:
		0:
			chance_container.visible = false
		1,2:
			chance_container.visible = true
	pass
