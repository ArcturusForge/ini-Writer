extends HBoxContainer

#-- Scene Refs
onready var skill_select:OptionButton = $VBoxContainer/SkillSelect
onready var skill_range_button:Button = $VBoxContainer/HBoxContainer/SkillRangeButton
onready var min_skill_spin_box:SpinBox = $VBoxContainer/HBoxContainer/MinSkillSpinBox
onready var max_skill_spin_box:SpinBox = $VBoxContainer/HBoxContainer/MaxSkillSpinBox

#-- Dynamic Vars
var filter
var index
var locked_range
var unlocked_range

func assign(filter, index, locked_range, unlocked_range):
	self.filter = filter
	self.index = index
	self.locked_range = locked_range
	self.unlocked_range = unlocked_range
	_on_SkillRangeButton_pressed()
	pass

func set_value(skill:int, value1:int, value2:int):
	skill_select.select(skill)
	if value2 > -1:
		skill_range_button.pressed = true
		_on_SkillRangeButton_pressed()
		max_skill_spin_box.value = value2
	min_skill_spin_box.value = value1
	pass

func get_value():
	var value = str(skill_select.selected) + "(" + str(min_skill_spin_box.value)
	if skill_range_button.pressed:
		value += "/" + str(max_skill_spin_box.value)
	value += ")"
	return value

func removed_index(removedIndex:int):
	if removedIndex < index:
		index -= 1
	pass

func _on_SkillRangeButton_pressed():
	if skill_range_button.pressed:
		skill_range_button.icon = unlocked_range
		max_skill_spin_box.editable = true
	else:
		skill_range_button.icon = locked_range
		max_skill_spin_box.editable = false
	max_skill_spin_box.value = min_skill_spin_box.value
	pass

func _on_DeleteButton_pressed():
	filter.remove_node(index)
	pass
