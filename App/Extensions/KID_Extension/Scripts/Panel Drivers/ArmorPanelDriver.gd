extends PanelContainer

#-- Scene Refs
onready var e_check_box:CheckBox = $VBoxContainer/HBoxContainer2/VBoxContainer/E_CheckBox
onready var e_exclude_check_box:CheckBox = $VBoxContainer/HBoxContainer2/VBoxContainer2/E_ExcludeCheckBox
onready var t_check_box:CheckBox = $VBoxContainer/HBoxContainer2/VBoxContainer/T_CheckBox
onready var t_exclude_check_box:CheckBox = $VBoxContainer/HBoxContainer2/VBoxContainer2/T_ExcludeCheckBox

onready var category_select:OptionButton = $VBoxContainer/CategorySelect
onready var body_select:OptionButton = $VBoxContainer/CategorySelect2

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
		elif "heavy" in lt || "light" in lt || "clothing" in lt:
			match lt:
				"heavy":
					category_select.selected = 1
				"light":
					category_select.selected = 2
				"clothing":
					category_select.selected = 3
		else:
			match int(lt):
				30:#- Head
					body_select.select(1)
				31:#- Hair
					body_select.select(2)
				32:#- Full Body
					body_select.select(3)
				33:#- Hands
					body_select.select(4)
				34:#- Forearms
					body_select.select(5)
				35:#- Amulet
					body_select.select(6)
				36:#- Ring
					body_select.select(7)
				37:#- Feet
					body_select.select(8)
				38:#- Calves
					body_select.select(9)
				39:#- Shield
					body_select.select(10)
				40:#- Tail
					body_select.select(11)
				41:#- Long Hair
					body_select.select(12)
				42:#- Circlet
					body_select.select(13)
				43:#- Ears
					body_select.select(14)
				44:#- Face/Mouth
					body_select.select(19)
				45:#- Neck
					body_select.select(20)
				46:#- Chest 1
					body_select.select(21)
				47:#- Back
					body_select.select(23)
				48:#- Misc 1
					body_select.select(24)
				49:#- Pelvis 1
					body_select.select(25)
				50:#- Decapitated Head
					body_select.select(15)
				51:#- Decapitate (???)
					body_select.select(16)
				52:#- Pelvis 2
					body_select.select(26)
				53:#- Leg 1
					body_select.select(27)
				54:#- Leg 2
					body_select.select(28)
				55:#- Face Alt
					body_select.select(29)
				56:#- Chest 2
					body_select.select(22)
				57:#- Shoulder
					body_select.select(30)
				58:#- Arm 2
					body_select.select(32)
				59:#- Arm 1
					body_select.select(31)
				60:#- Misc 2
					body_select.select(33)
				61:#- FX01
					body_select.select(17)
	
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
	
	if body_select.selected > 0:
		match body_select.selected:
				1:#- Head
					edit.traitFilters.append(str(30))
				2:#- Hair
					edit.traitFilters.append(str(31))
				3:#- Full Body
					edit.traitFilters.append(str(32))
				4:#- Hands
					edit.traitFilters.append(str(33))
				5:#- Forearms
					edit.traitFilters.append(str(34))
				6:#- Amulet
					edit.traitFilters.append(str(35))
				7:#- Ring
					edit.traitFilters.append(str(36))
				8:#- Feet
					edit.traitFilters.append(str(37))
				9:#- Calves
					edit.traitFilters.append(str(38))
				10:#- Shield
					edit.traitFilters.append(str(39))
				11:#- Tail
					edit.traitFilters.append(str(40))
				12:#- Long Hair
					edit.traitFilters.append(str(41))
				13:#- Circlet
					edit.traitFilters.append(str(42))
				14:#- Ears
					edit.traitFilters.append(str(43))
				19:#- Face/Mouth
					edit.traitFilters.append(str(44))
				20:#- Neck
					edit.traitFilters.append(str(45))
				21:#- Chest 1
					edit.traitFilters.append(str(46))
				23:#- Back
					edit.traitFilters.append(str(47))
				24:#- Misc 1
					edit.traitFilters.append(str(48))
				25:#- Pelvis 1
					edit.traitFilters.append(str(49))
				15:#- Decapitated Head
					edit.traitFilters.append(str(50))
				16:#- Decapitate (???)
					edit.traitFilters.append(str(51))
				26:#- Pelvis 2
					edit.traitFilters.append(str(52))
				27:#- Leg 1
					edit.traitFilters.append(str(53))
				28:#- Leg 2
					edit.traitFilters.append(str(54))
				29:#- Face Alt
					edit.traitFilters.append(str(55))
				22:#- Chest 2
					edit.traitFilters.append(str(56))
				30:#- Shoulder
					edit.traitFilters.append(str(57))
				32:#- Arm 2
					edit.traitFilters.append(str(58))
				31:#- Arm 1
					edit.traitFilters.append(str(59))
				33:#- Misc 2
					edit.traitFilters.append(str(60))
				17:#- FX01
					edit.traitFilters.append(str(61))
	
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

