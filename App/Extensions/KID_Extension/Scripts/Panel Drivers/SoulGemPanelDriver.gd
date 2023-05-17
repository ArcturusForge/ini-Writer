extends PanelContainer

#-- Scene Refs
onready var b_check_box = $VBoxContainer/HBoxContainer2/VBoxContainer/B_CheckBox
onready var b_exclude_check_box = $VBoxContainer/HBoxContainer2/VBoxContainer2/B_ExcludeCheckBox

onready var soul_size_select = $VBoxContainer/SoulSizeSelect
onready var gem_size_select = $VBoxContainer/GemSizeSelect


#--- SYSTEM: Reset ui to init user state.
func init():
	_on_B_CheckBox_pressed()
	pass

#--- Used to init the ui.
func set_data(edit):
	for trait in edit.traitFilters:
		var lt = trait.to_lower()
		if "black" == lt:
			b_check_box.pressed = true
		elif "-black" == lt:
			b_check_box.pressed = true
			b_exclude_check_box.pressed = true
		elif "soul(" in lt:
			## soul_size_select.selected = int(lt.replace("soul(", "").replace(")", ""))
		elif "gem(" in lt:
			##
	init()
	pass

#--- Used to compile the data into an edit.
#--- [edit] is an instance reference so changes will apply for all viewers.
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

