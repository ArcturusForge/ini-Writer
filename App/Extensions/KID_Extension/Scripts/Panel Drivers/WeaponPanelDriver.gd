extends PanelContainer

#-- Scene Refs
onready var e_check_box:CheckBox = $VBoxContainer/HBoxContainer2/VBoxContainer/E_CheckBox
onready var e_exclude_check_box:CheckBox = $VBoxContainer/HBoxContainer2/VBoxContainer2/E_ExcludeCheckBox
onready var t_check_box:CheckBox = $VBoxContainer/HBoxContainer2/VBoxContainer/T_CheckBox
onready var t_exclude_check_box:CheckBox = $VBoxContainer/HBoxContainer2/VBoxContainer2/T_ExcludeCheckBox

onready var category_select:OptionButton = $VBoxContainer/CategorySelect

onready var weight_check_button:CheckButton = $VBoxContainer/WeightCheckButton
onready var weight_sub_panel = $VBoxContainer/WeightSubPanel
onready var weight_min_spin_box:SpinBox = $VBoxContainer/WeightSubPanel/NodeContainer/HBoxContainer/WeightMinSpinBox
onready var weight_range_button:Button = $VBoxContainer/WeightSubPanel/NodeContainer/HBoxContainer/WeightRangeButton
onready var weight_max_spin_box:SpinBox = $VBoxContainer/WeightSubPanel/NodeContainer/HBoxContainer/WeightMaxSpinBox

onready var damage_check_button:CheckButton = $VBoxContainer/DamageCheckButton
onready var damage_sub_panel = $VBoxContainer/DamageSubPanel
onready var damage_min_spin_box:SpinBox = $VBoxContainer/DamageSubPanel/NodeContainer/HBoxContainer/MinSpinBox
onready var damage_range_button:Button = $VBoxContainer/DamageSubPanel/NodeContainer/HBoxContainer/DamageRangeButton
onready var damage_max_spin_box:SpinBox = $VBoxContainer/DamageSubPanel/NodeContainer/HBoxContainer/MaxSpinBox

#-- Icon Paths
var locked = "res://Internal/Default/Icons/lock_closed.png"
var unlocked = "res://Internal/Default/Icons/lock_open.png"

#--- SYSTEM: Reset ui to init user state.
func init():
	_on_E_CheckBox_pressed()
	_on_T_CheckBox_pressed()
	_on_WeightCheckButton_toggled(weight_check_button.pressed)
	_on_WeightRangeButton_toggled(weight_range_button.pressed)
	_on_DamageCheckButton_toggled(damage_check_button.pressed)
	_on_DamageRangeButton_toggled(damage_range_button.pressed)
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
		elif "d(" in lt:
			damage_check_button.pressed = true
			var vals = lt.replace("d(", "").replace(")", "")
			if "/" in trait:
				damage_range_button.pressed = true
				damage_min_spin_box.value = float(vals.get_slice("/", 0))
				damage_max_spin_box.value = float(vals.get_slice("/", 1))
			else:
				damage_min_spin_box.value = float(vals)
		else:
			match lt:
				"handtohandmelee":
					category_select.selected = 1
				"onehandsword":
					category_select.selected = 2
				"onehanddagger":
					category_select.selected = 3
				"onehandaxe":
					category_select.selected = 4
				"onehandmace":
					category_select.selected = 5
				"twohandsword":
					category_select.selected = 6
				"twohandaxe":
					category_select.selected = 7
				"bow":
					category_select.selected = 8
				"staff":
					category_select.selected = 9
				"crossbow":
					category_select.selected = 10
	
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
				edit.traitFilters.append("HandToHandMelee")
			2:
				edit.traitFilters.append("OneHandSword")
			3:
				edit.traitFilters.append("OneHandDagger")
			4:
				edit.traitFilters.append("OneHandAxe")
			5:
				edit.traitFilters.append("OneHandMace")
			6:
				edit.traitFilters.append("TwoHandSword")
			7:
				edit.traitFilters.append("TwoHandAxe")
			8:
				edit.traitFilters.append("Bow")
			9:
				edit.traitFilters.append("Staff")
			10:
				edit.traitFilters.append("Crossbow")
	
	if weight_check_button.pressed:
		var wfilt = "W(" + str(weight_min_spin_box.value)
		if weight_range_button.pressed:
			wfilt += "/"+ str(weight_max_spin_box.value)
		wfilt += ")"
		edit.traitFilters.append(wfilt)
	
	if damage_check_button.pressed:
		var dfilt = "D(" + str(damage_min_spin_box.value)
		if damage_range_button.pressed:
			dfilt += "/"+ str(damage_max_spin_box.value)
		dfilt += ")"
		edit.traitFilters.append(dfilt)
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

#--- CUSTOM: Toggles damage sub-panel.
func _on_DamageCheckButton_toggled(state):
	damage_sub_panel.visible = state
	pass

#--- CUSTOM: Toggles damage range editable state.
func _on_DamageRangeButton_toggled(state):
	damage_max_spin_box.editable = state
	if state:
		damage_range_button.icon = Functions.load_image(unlocked)
	else:
		damage_range_button.icon = Functions.load_image(locked)
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
