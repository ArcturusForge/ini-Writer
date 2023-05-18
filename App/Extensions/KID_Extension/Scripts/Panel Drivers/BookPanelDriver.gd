extends PanelContainer

#-- Scene Refs
onready var s_check_box = $VBoxContainer/HBoxContainer2/VBoxContainer/S_CheckBox
onready var s_exclude_check_box = $VBoxContainer/HBoxContainer2/VBoxContainer2/S_ExcludeCheckBox
onready var t_check_box = $VBoxContainer/HBoxContainer2/VBoxContainer/T_CheckBox
onready var t_exclude_check_box = $VBoxContainer/HBoxContainer2/VBoxContainer2/T_ExcludeCheckBox

onready var school_select = $VBoxContainer/SchoolSelect

#--- SYSTEM: Reset ui to init user state.
func init():
	_on_S_CheckBox_pressed()
	_on_T_CheckBox_pressed()
	pass

#--- Used to init the ui.
func set_data(edit):
	for trait in edit.traitFilters:
		var lt = trait.to_lower()
		if "s" == lt:
			s_check_box.pressed = true
		elif "-s" == lt:
			s_check_box.pressed = true
			s_exclude_check_box.pressed = true
		if "av" == lt:
			t_check_box.pressed = true
		elif "-av" == lt:
			t_check_box.pressed = true
			t_exclude_check_box.pressed = true
		else:
			match int(lt):
				18: #- Alteration 
					school_select.selected = 1
				19:#- Conjuration 
					school_select.selected = 2
				20: #- Destruction 
					school_select.selected = 3
				21: #- Illusion 
					school_select.selected = 4
				22: #- Restoration 
					school_select.selected = 5
	init()
	pass

#--- Used to compile the data into an edit.
#--- [edit] is an instance reference so changes will apply for all ref holders.
func apply_data(edit):
	if s_check_box.pressed:
		var sfilt = ""
		if s_exclude_check_box.pressed:
			sfilt += "-"
		sfilt += "S"
		edit.traitFilters.append(sfilt)
	
	if t_check_box.pressed:
		var tfilt = ""
		if t_exclude_check_box.pressed:
			tfilt += "-"
		tfilt += "AV"
		edit.traitFilters.append(tfilt)
	
	match school_select.selected:
		1: #- Alteration 
			edit.traitFilters.append(str(18))
		2:#- Conjuration 
			edit.traitFilters.append(str(19))
		3: #- Destruction 
			edit.traitFilters.append(str(20))
		4: #- Illusion 
			edit.traitFilters.append(str(21))
		5: #- Restoration 
			edit.traitFilters.append(str(22))
	pass

#--- CUSTOM: Toggles enchanted exclude button editable state.
func _on_S_CheckBox_pressed():
	s_exclude_check_box.disabled = !s_check_box.pressed
	if !s_check_box.pressed:
		s_exclude_check_box.pressed = false
	pass

#--- CUSTOM: Toggles enchanted exclude button editable state.
func _on_T_CheckBox_pressed():
	t_exclude_check_box.disabled = !t_check_box.pressed
	if !t_check_box.pressed:
		t_exclude_check_box.pressed = false
	pass
