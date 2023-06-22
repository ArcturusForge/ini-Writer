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
	var chance = edit.chance
	chance = chance.replace("chance", "")
	if "R" in chance:
		option_button.select(2)
		spin_box.value = float(chance.get_slice("(", 1).replace(")", ""))
	elif not chance == "":
		option_button.select(1)
		spin_box.value = float(chance.get_slice("(", 1).replace(")", ""))
	
	handle_chance(option_button.selected)
	pass

func get_data():
	var results = []
	match option_button.selected:
		1:
			results.append("chanceS(" + str(spin_box.value) + ")")
		2:
			results.append("chanceR(" + str(spin_box.value) + ")")
	return results

func handle_chance(index):
	match index:
		0:
			chance_container.visible = false
		1,2:
			chance_container.visible = true
	pass
