extends PanelContainer

#-- Scene Refs
onready var b_check_box:CheckBox = $VBoxContainer/HBoxContainer2/VBoxContainer/B_CheckBox
onready var b_exclude_check_box:CheckBox = $VBoxContainer/HBoxContainer2/VBoxContainer2/B_ExcludeCheckBox

onready var damage_check_button = $VBoxContainer/DamageCheckButton
onready var damage_sub_panel = $VBoxContainer/DamageSubPanel
onready var damage_min_spin_box = $VBoxContainer/DamageSubPanel/NodeContainer/HBoxContainer/DamageMinSpinBox
onready var damage_range_button = $VBoxContainer/DamageSubPanel/NodeContainer/HBoxContainer/DamageRangeButton
onready var damage_max_spin_box = $VBoxContainer/DamageSubPanel/NodeContainer/HBoxContainer/DamageMaxSpinBox

#-- Icon Paths
var locked = "res://Internal/Default/Icons/lock_closed.png"
var unlocked = "res://Internal/Default/Icons/lock_open.png"

#--- SYSTEM: Reset ui to init user state.
func init():
	_on_B_CheckBox_pressed()
	_on_DamageCheckButton_toggled(damage_check_button.pressed)
	_on_DamageRangeButton_toggled(damage_range_button.pressed)
	pass

#--- Used to init the ui.
func set_data(edit):
	for trait in edit.traitFilters:
		var lt = trait.to_lower()
		if "b" == lt:
			b_check_box.pressed = true
		elif "-b" == lt:
			b_check_box.pressed = true
			b_exclude_check_box.pressed = true
		elif "d(" in lt:
			damage_check_button.pressed = true
			var vals = lt.replace("d(", "").replace(")", "")
			if "/" in trait:
				damage_range_button.pressed = true
				damage_min_spin_box.value = float(vals.get_slice("/", 0))
				damage_max_spin_box.value = float(vals.get_slice("/", 1))
			else:
				damage_min_spin_box.value = float(vals)
	init()
	pass

#--- Used to compile the data into an edit.
#--- [edit] is an instance reference so changes will apply for all ref holders.
func apply_data(edit):
	if b_check_box.pressed:
		var bfilt = ""
		if b_exclude_check_box.pressed:
			bfilt += "-"
		bfilt += "B"
		edit.traitFilters.append(bfilt)
	
	if damage_check_button.pressed:
		var dfilt = "D(" + str(damage_min_spin_box.value)
		if damage_range_button.pressed:
			dfilt += "/"+ str(damage_max_spin_box.value)
		dfilt += ")"
		edit.traitFilters.append(dfilt)
	pass

#--- CUSTOM: Toggles rating sub-panel.
func _on_DamageCheckButton_toggled(state):
	damage_sub_panel.visible = state
	pass

#--- CUSTOM: Toggles rating range editable state.
func _on_DamageRangeButton_toggled(state):
	damage_max_spin_box.editable = state
	if state:
		damage_range_button.icon = Functions.load_image(unlocked)
	else:
		damage_range_button.icon = Functions.load_image(locked)
	pass

#--- CUSTOM: Toggles enchanted exclude button editable state.
func _on_B_CheckBox_pressed():
	b_exclude_check_box.disabled = !b_check_box.pressed
	if !b_check_box.pressed:
		b_exclude_check_box.pressed = false
	pass

