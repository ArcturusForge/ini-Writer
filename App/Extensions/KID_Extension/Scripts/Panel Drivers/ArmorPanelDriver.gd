extends PanelContainer

#-- Scene Refs
onready var e_check_box:CheckBox = $VBoxContainer/HBoxContainer2/VBoxContainer/E_CheckBox
onready var e_exclude_check_box:CheckBox = $VBoxContainer/HBoxContainer2/VBoxContainer2/E_ExcludeCheckBox
onready var t_check_box:CheckBox = $VBoxContainer/HBoxContainer2/VBoxContainer/T_CheckBox
onready var t_exclude_check_box:CheckBox = $VBoxContainer/HBoxContainer2/VBoxContainer2/T_ExcludeCheckBox

onready var category_select:OptionButton = $VBoxContainer/CategorySelect

onready var rating_check_button = $VBoxContainer/RatingCheckButton
onready var rating_sub_panel = $VBoxContainer/RatingSubPanel
onready var rating_min_spin_box = $VBoxContainer/RatingSubPanel/NodeContainer/HBoxContainer/RatingMinSpinBox
onready var rating_range_button = $VBoxContainer/RatingSubPanel/NodeContainer/HBoxContainer/RatingRangeButton
onready var rating_max_spin_box = $VBoxContainer/RatingSubPanel/NodeContainer/HBoxContainer/RatingMaxSpinBox

onready var weight_check_button:CheckButton = $VBoxContainer/WeightCheckButton
onready var weight_sub_panel = $VBoxContainer/WeightSubPanel
onready var weight_min_spin_box:SpinBox = $VBoxContainer/WeightSubPanel/NodeContainer/HBoxContainer/WeightMinSpinBox
onready var weight_range_button:Button = $VBoxContainer/WeightSubPanel/NodeContainer/HBoxContainer/WeightRangeButton
onready var weight_max_spin_box:SpinBox = $VBoxContainer/WeightSubPanel/NodeContainer/HBoxContainer/WeightMaxSpinBox

#-- Icon Paths
var locked = "res://Internal/Default/Icons/lock_closed.png"
var unlocked = "res://Internal/Default/Icons/lock_open.png"

#--- SYSTEM: Reset ui to init user state.
func init():
	_on_E_CheckBox_pressed()
	_on_T_CheckBox_pressed()
	_on_WeightCheckButton_toggled(weight_check_button.pressed)
	_on_WeightRangeButton_toggled(weight_range_button.pressed)
	_on_RatingCheckButton_toggled(rating_check_button.pressed)
	_on_RatingRangeButton_toggled(rating_range_button.pressed)
	pass

#--- Used to init the ui.
func set_data(edit):
	for trait in edit.traitFilters:
		var lt = trait.to_lower()
		if "e" == lt:
			e_check_box.pressed = true
		elif "-e" == lt:
			e_check_box.pressed = true
			e_exclude_check_box.pressed = true
		elif "t" == lt:
			t_check_box.pressed = true
		elif "-t" == lt:
			t_check_box.pressed = true
			t_exclude_check_box.pressed = true
		elif "w(" in lt:
			weight_check_button.pressed = true
			var vals = lt.replace("w(", "").replace(")", "")
			if "/" in trait:
				weight_range_button.pressed = true
				weight_min_spin_box.value = float(vals.get_slice("/", 0))
				weight_max_spin_box.value = float(vals.get_slice("/", 1))
			else:
				weight_min_spin_box.value = float(vals)
		elif "ar(" in lt:
			rating_check_button.pressed = true
			var vals = lt.replace("ar(", "").replace(")", "")
			if "/" in trait:
				rating_range_button.pressed = true
				rating_min_spin_box.value = float(vals.get_slice("/", 0))
				rating_max_spin_box.value = float(vals.get_slice("/", 1))
			else:
				rating_min_spin_box.value = float(vals)
		else:
			match lt:
				"heavy":
					category_select.selected = 1
				"light":
					category_select.selected = 2
				"clothing":
					category_select.selected = 3
	
	init()
	pass

#--- Used to compile the data into an edit.
#--- [edit] is an instance reference so changes will apply for all ref holders.
func apply_data(edit):
	if e_check_box.pressed:
		var efilt = ""
		if e_exclude_check_box.pressed:
			efilt += "-"
		efilt += "E"
		edit.traitFilters.append(efilt)
	
	if t_check_box.pressed:
		var tfilt = ""
		if t_exclude_check_box.pressed:
			tfilt += "-"
		tfilt += "T"
		edit.traitFilters.append(tfilt)

	if category_select.selected > 0:
		match category_select.selected:
			1:
				edit.traitFilters.append("HEAVY")
			2:
				edit.traitFilters.append("LIGHT")
			3:
				edit.traitFilters.append("CLOTHING")
	
	if rating_check_button.pressed:
		var rfilt = "AR(" + str(rating_min_spin_box.value)
		if rating_range_button.pressed:
			rfilt += "/"+ str(rating_max_spin_box.value)
		rfilt += ")"
		edit.traitFilters.append(rfilt)
	
	if weight_check_button.pressed:
		var wfilt = "W(" + str(weight_min_spin_box.value)
		if weight_range_button.pressed:
			wfilt += "/"+ str(weight_max_spin_box.value)
		wfilt += ")"
		edit.traitFilters.append(wfilt)
	pass

#--- CUSTOM: Toggles weight sub-panel.
func _on_WeightCheckButton_toggled(state):
	weight_sub_panel.visible = state
	pass

#--- CUSTOM: Toggles weight range editable state.
func _on_WeightRangeButton_toggled(state):
	weight_max_spin_box.editable = state
	if state:
		weight_range_button.icon = Functions.load_image(unlocked)
	else:
		weight_range_button.icon = Functions.load_image(locked)
	pass

#--- CUSTOM: Toggles rating sub-panel.
func _on_RatingCheckButton_toggled(state):
	rating_sub_panel.visible = state
	pass

#--- CUSTOM: Toggles rating range editable state.
func _on_RatingRangeButton_toggled(state):
	rating_max_spin_box.editable = state
	if state:
		rating_range_button.icon = Functions.load_image(unlocked)
	else:
		rating_range_button.icon = Functions.load_image(locked)
	pass

#--- CUSTOM: Toggles enchanted exclude button editable state.
func _on_E_CheckBox_pressed():
	e_exclude_check_box.disabled = !e_check_box.pressed
	if !e_check_box.pressed:
		e_exclude_check_box.pressed = false
	pass

#--- CUSTOM: Toggles template exclude button editable state.
func _on_T_CheckBox_pressed():
	t_exclude_check_box.disabled = !t_check_box.pressed
	if !t_check_box.pressed:
		t_exclude_check_box.pressed = false
	pass

