extends PanelContainer

#-- Scene Refs
onready var f_check_box = $VBoxContainer/HBoxContainer2/VBoxContainer/F_CheckBox
onready var f_exclude_check_box = $VBoxContainer/HBoxContainer2/VBoxContainer2/F_ExcludeCheckBox

#--- SYSTEM: Reset ui to init user state.
func init():
	_on_F_CheckBox_pressed()
	pass

#--- Used to init the ui.
func set_data(edit):
	for trait in edit.traitFilters:
		var lt = trait.to_lower()
		if "f" == lt:
			f_check_box.pressed = true
		elif "-f" == lt:
			f_check_box.pressed = true
			f_exclude_check_box.pressed = true
	init()
	pass

#--- Used to compile the data into an edit.
#--- [edit] is an instance reference so changes will apply for all viewers.
func apply_data(edit):
	if f_check_box.pressed:
		var ffilt = ""
		if f_exclude_check_box.pressed:
			ffilt += "-"
		ffilt += "F"
		edit.traitFilters.append(ffilt)
	pass

#--- CUSTOM: Toggles food exclude button editable state.
func _on_F_CheckBox_pressed():
	f_exclude_check_box.disabled = !f_check_box.pressed
	if !f_check_box.pressed:
		f_exclude_check_box.pressed = false
	pass
