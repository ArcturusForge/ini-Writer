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
			soul_size_select.selected = int(lt.replace("soul(", "").replace(")", "")) + 1
		elif "gem(" in lt:
			gem_size_select.selected = int(lt.replace("gem(", "").replace(")", "")) + 1
	init()
	pass

#--- Used to compile the data into an edit.
#--- [edit] is an instance reference so changes will apply for all ref holders.
func apply_data(edit):
	if b_check_box.pressed:
		var bfilt = ""
		if b_exclude_check_box.pressed:
			bfilt += "-"
		bfilt += "BLACK"
		edit.traitFilters.append(bfilt)
	
	if soul_size_select.selected > 0:
		edit.traitFilters.append("SOUL(" + str(soul_size_select.selected - 1) + ")")
	
	if gem_size_select.selected > 0:
		edit.traitFilters.append("GEM(" + str(gem_size_select.selected - 1) + ")")
	pass

#--- CUSTOM: Toggles enchanted exclude button editable state.
func _on_B_CheckBox_pressed():
	b_exclude_check_box.disabled = !b_check_box.pressed
	if !b_check_box.pressed:
		b_exclude_check_box.pressed = false
	pass

