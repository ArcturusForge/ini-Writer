extends PanelContainer

#-- Scene Refs
onready var h_check_box = $VBoxContainer/HBoxContainer2/VBoxContainer/H_CheckBox
onready var h_exclude_check_box = $VBoxContainer/HBoxContainer2/VBoxContainer2/H_ExcludeCheckBox

onready var delivery_type_select = $VBoxContainer/DeliveryTypeSelect
onready var casting_type_select = $VBoxContainer/CastingTypeSelect

onready var school_check_button = $VBoxContainer/SchoolCheckButton
onready var school_sub_panel = $VBoxContainer/SchoolSubPanel
onready var school_select = $VBoxContainer/SchoolSubPanel/NodeContainer/SchoolSelect
onready var school_min_spin_box = $VBoxContainer/SchoolSubPanel/NodeContainer/HBoxContainer/SchoolMinSpinBox
onready var school_range_button = $VBoxContainer/SchoolSubPanel/NodeContainer/HBoxContainer/SchoolRangeButton
onready var school_max_spin_box = $VBoxContainer/SchoolSubPanel/NodeContainer/HBoxContainer/SchoolMaxSpinBox

#-- Icon Paths
var locked = "res://Internal/Default/Icons/lock_closed.png"
var unlocked = "res://Internal/Default/Icons/lock_open.png"

#--- SYSTEM: Reset ui to init user state.
func init():
	_on_H_CheckBox_pressed()
	_on_SchoolCheckButton_toggled(school_check_button.pressed)
	_on_SchoolRangeButton_toggled(school_range_button.pressed)
	pass

#--- Used to init the ui.
func set_data(edit):
	for trait in edit.traitFilters:
		var lt = trait.to_lower()
		if "h" == lt:
			h_check_box.pressed = true
		elif "-h" == lt:
			h_check_box.pressed = true
			h_exclude_check_box.pressed = true
		elif "d(" in lt:
			delivery_type_select.selected = int(lt.replace("d(", "").replace(")", "")) + 1
		elif "ct(" in lt:
			casting_type_select.selected = int(lt.replace("ct(", "").replace(")", "")) + 1
		elif "18(" in lt || "19(" in lt || "20(" in lt || "21(" in lt || "22(" in lt:
			school_check_button.pressed = true
			var vals = lt.replace(")", "").split("(", false)
			match int(vals[0]):
				18: #- Alteration 
					school_select.selected = 0
				19:#- Conjuration 
					school_select.selected = 1
				20: #- Destruction 
					school_select.selected = 2
				21: #- Illusion 
					school_select.selected = 3
				22: #- Restoration 
					school_select.selected = 4
			if "/" in trait:
				school_range_button.pressed = true
				school_min_spin_box.value = float(vals[1].get_slice("/", 0))
				school_max_spin_box.value = float(vals[1].get_slice("/", 1))
			else:
				school_min_spin_box.value = float(vals[1])
	init()
	pass

#--- Used to compile the data into an edit.
#--- [edit] is an instance reference so changes will apply for all viewers.
func apply_data(edit):
	if h_check_box.pressed:
		var hfilt = ""
		if h_exclude_check_box.pressed:
			hfilt += "-"
		hfilt += "H"
		edit.traitFilters.append(hfilt)
	
	if delivery_type_select.selected > 0:
		edit.traitFilters.append("D(" + str(delivery_type_select.selected - 1) + ")")
	
	if casting_type_select.selected > 0:
		edit.traitFilters.append("CT(" + str(casting_type_select.selected - 1) + ")")
	
	if school_check_button.pressed:
		var sfilt = ""
		match school_select.selected:
			0: #- Alteration 
				sfilt += str(18)
			1:#- Conjuration 
				sfilt += str(19)
			2: #- Destruction 
				sfilt += str(20)
			3: #- Illusion 
				sfilt += str(21)
			4: #- Restoration 
				sfilt += str(22)
		sfilt += "(" + str(school_min_spin_box.value)
		if school_range_button.pressed:
			sfilt += "/"+ str(school_max_spin_box.value)
		sfilt += ")"
		edit.traitFilters.append(sfilt)
	pass

#--- CUSTOM: Toggles weight sub-panel.
func _on_SchoolCheckButton_toggled(state):
	school_sub_panel.visible = state
	pass

#--- CUSTOM: Toggles weight range editable state.
func _on_SchoolRangeButton_toggled(state):
	school_max_spin_box.editable = state
	if state:
		school_range_button.icon = Functions.load_image(unlocked)
	else:
		school_range_button.icon = Functions.load_image(locked)
	pass

#--- CUSTOM: Toggles enchanted exclude button editable state.
func _on_H_CheckBox_pressed():
	h_exclude_check_box.disabled = !h_check_box.pressed
	if !h_check_box.pressed:
		h_exclude_check_box.pressed = false
	pass

