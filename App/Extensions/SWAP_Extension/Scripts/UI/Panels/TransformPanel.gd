extends PanelContainer

#-- Scene Refs
onready var pos_check_button = $VBoxContainer/SubPanel/NodeContainer/HBoxContainer4/CheckButton
onready var rot_check_button = $VBoxContainer/SubPanel2/NodeContainer/HBoxContainer4/CheckButton
onready var sca_check_button = $VBoxContainer/SubPanel3/NodeContainer/HBoxContainer4/CheckButton
onready var pos_v_box_container = $VBoxContainer/SubPanel/NodeContainer/VBoxContainer
onready var rot_v_box_container = $VBoxContainer/SubPanel2/NodeContainer/VBoxContainer
onready var sca_v_box_container = $VBoxContainer/SubPanel3/NodeContainer/VBoxContainer

#- Position
onready var p_option_button = $VBoxContainer/SubPanel/NodeContainer/VBoxContainer/OptionButton
onready var px_spin_box = $VBoxContainer/SubPanel/NodeContainer/VBoxContainer/HBoxContainer/HBoxContainer/SpinBox
onready var px_range_button = $VBoxContainer/SubPanel/NodeContainer/VBoxContainer/HBoxContainer/HBoxContainer/RangeButton
onready var px_spin_box_2 = $VBoxContainer/SubPanel/NodeContainer/VBoxContainer/HBoxContainer/HBoxContainer/SpinBox2
onready var py_spin_box = $VBoxContainer/SubPanel/NodeContainer/VBoxContainer/HBoxContainer2/HBoxContainer/SpinBox
onready var py_range_button = $VBoxContainer/SubPanel/NodeContainer/VBoxContainer/HBoxContainer2/HBoxContainer/RangeButton
onready var py_spin_box_2 = $VBoxContainer/SubPanel/NodeContainer/VBoxContainer/HBoxContainer2/HBoxContainer/SpinBox2
onready var pz_spin_box = $VBoxContainer/SubPanel/NodeContainer/VBoxContainer/HBoxContainer3/HBoxContainer/SpinBox
onready var pz_range_button = $VBoxContainer/SubPanel/NodeContainer/VBoxContainer/HBoxContainer3/HBoxContainer/RangeButton
onready var pz_spin_box_2 = $VBoxContainer/SubPanel/NodeContainer/VBoxContainer/HBoxContainer3/HBoxContainer/SpinBox2

#- Rotation
onready var r_option_button = $VBoxContainer/SubPanel2/NodeContainer/VBoxContainer/OptionButton
onready var rx_spin_box = $VBoxContainer/SubPanel2/NodeContainer/VBoxContainer/HBoxContainer/HBoxContainer/SpinBox
onready var rx_range_button = $VBoxContainer/SubPanel2/NodeContainer/VBoxContainer/HBoxContainer/HBoxContainer/RangeButton
onready var rx_spin_box_2 = $VBoxContainer/SubPanel2/NodeContainer/VBoxContainer/HBoxContainer/HBoxContainer/SpinBox2
onready var ry_spin_box = $VBoxContainer/SubPanel2/NodeContainer/VBoxContainer/HBoxContainer2/HBoxContainer/SpinBox
onready var ry_range_button = $VBoxContainer/SubPanel2/NodeContainer/VBoxContainer/HBoxContainer2/HBoxContainer/RangeButton
onready var ry_spin_box_2 = $VBoxContainer/SubPanel2/NodeContainer/VBoxContainer/HBoxContainer2/HBoxContainer/SpinBox2
onready var rz_spin_box = $VBoxContainer/SubPanel2/NodeContainer/VBoxContainer/HBoxContainer3/HBoxContainer/SpinBox
onready var rz_range_button = $VBoxContainer/SubPanel2/NodeContainer/VBoxContainer/HBoxContainer3/HBoxContainer/RangeButton
onready var rz_spin_box_2 = $VBoxContainer/SubPanel2/NodeContainer/VBoxContainer/HBoxContainer3/HBoxContainer/SpinBox2

#- Scale
onready var s_min_spin_box = $VBoxContainer/SubPanel3/NodeContainer/VBoxContainer/HBoxContainer/MinSpinBox
onready var s_range_button = $VBoxContainer/SubPanel3/NodeContainer/VBoxContainer/HBoxContainer/RangeButton
onready var s_max_spin_box = $VBoxContainer/SubPanel3/NodeContainer/VBoxContainer/HBoxContainer/MaxSpinBox

#-- Prefabs
#-- Icons
var locked = "res://Internal/Default/Icons/lock_closed.png"
var unlocked = "res://Internal/Default/Icons/lock_open.png"

func _ready():
	pos_toggled(false)
	rot_toggled(false)
	sca_toggled(false)
	px_toggled(false)
	py_toggled(false)
	pz_toggled(false)
	rx_toggled(false)
	ry_toggled(false)
	rz_toggled(false)
	s_toggled(false)
	pos_check_button.connect("toggled", self, "pos_toggled")
	rot_check_button.connect("toggled", self, "rot_toggled")
	sca_check_button.connect("toggled", self, "sca_toggled")
	
	px_range_button.connect("toggled", self, "px_toggled")
	py_range_button.connect("toggled", self, "py_toggled")
	pz_range_button.connect("toggled", self, "pz_toggled")
	
	rx_range_button.connect("toggled", self, "rx_toggled")
	ry_range_button.connect("toggled", self, "ry_toggled")
	rz_range_button.connect("toggled", self, "rz_toggled")
	
	s_range_button.connect("toggled", self, "s_toggled")
	pass

func set_data(edit):
	#- Position
	if not edit.transform.position == "":
		pos_toggled(true)
		var vals = edit.transform.position.replace("pos", "").replace("(", "").replace(")", "")
		p_option_button.select(1) if "A" in vals else p_option_button.select(0)
		vals = vals.replace("A", "").replace("R", "")
		var nums = vals.split(",", false)
		#- x
		if "/" in nums[0]:
			px_toggled(true)
			px_spin_box.value = float(nums[0].get_slice("/", 0))
			px_spin_box_2.value = float(nums[0].get_slice("/", 1))
		else:
			px_spin_box.value = float(nums[0])
		#- y
		if "/" in nums[1]:
			py_toggled(true)
			py_spin_box.value = float(nums[1].get_slice("/", 0))
			py_spin_box_2.value = float(nums[1].get_slice("/", 1))
		else:
			py_spin_box.value = float(nums[1])
		#- z
		if "/" in nums[2]:
			pz_toggled(true)
			pz_spin_box.value = float(nums[2].get_slice("/", 0))
			pz_spin_box_2.value = float(nums[2].get_slice("/", 1))
		else:
			pz_spin_box.value = float(nums[2])
	
	#- Rotation
	if not edit.transform.rotation == "":
		rot_toggled(true)
		var vals = edit.transform.rotation.replace("rot", "").replace("(", "").replace(")", "")
		r_option_button.select(1) if "A" in vals else r_option_button.select(0)
		vals = vals.replace("A", "").replace("R", "")
		var nums = vals.split(",", false)
		#- x
		if "/" in nums[0]:
			rx_toggled(true)
			rx_spin_box.value = float(nums[0].get_slice("/", 0))
			rx_spin_box_2.value = float(nums[0].get_slice("/", 1))
		else:
			rx_spin_box.value = float(nums[0])
		#- y
		if "/" in nums[1]:
			ry_toggled(true)
			ry_spin_box.value = float(nums[1].get_slice("/", 0))
			ry_spin_box_2.value = float(nums[1].get_slice("/", 1))
		else:
			ry_spin_box.value = float(nums[1])
		#- z
		if "/" in nums[2]:
			rz_toggled(true)
			rz_spin_box.value = float(nums[2].get_slice("/", 0))
			rz_spin_box_2.value = float(nums[2].get_slice("/", 1))
		else:
			rz_spin_box.value = float(nums[2])
	
	#- Scale
	if not edit.transform.scale == "":
		sca_toggled(true)
		var vals = edit.transform.scale.replace("scale", "").replace("(", "").replace(")", "").split(",", false)
		#- x
		if "/" in vals:
			rx_toggled(true)
			s_min_spin_box.value = float(vals.get_slice("/", 0))
			s_max_spin_box.value = float(vals.get_slice("/", 1))
		else:
			s_min_spin_box.value = float(vals)
	pass

func get_data():
	var results = []
	#- Position
	if pos_check_button.pressed == true:
		var line = "pos"
		match p_option_button.selected:
			0:#- Relative
				line += "R("
			1:#- Absolute
				line += "A("
		
		var x1 = ""
		var x2 = ""
		x1 = str(px_spin_box.value)
		x1 += ".0" if not "." in x1 else ""
		if px_range_button.pressed == true:
			x2 = "/" + str(px_spin_box_2.value)
			x2 += ".0" if not "." in x2 else ""
		
		var y1 = ""
		var y2 = ""
		y1 = str(py_spin_box.value)
		y1 += ".0" if not "." in y1 else ""
		if py_range_button.pressed == true:
			y2 = "/" + str(py_spin_box_2.value)
			y2 += ".0" if not "." in y2 else ""
		
		var z1 = ""
		var z2 = ""
		z1 = str(pz_spin_box.value)
		z1 += ".0" if not "." in z1 else ""
		if pz_range_button.pressed == true:
			z2 = "/" + str(pz_spin_box_2.value)
			z2 += ".0" if not "." in z2 else ""
		
		line += x1 + x2 + "," + y1 + y2 + "," + z1 + z2 + ")"
		results.append(line)
	
	#- Rotation
	if rot_check_button.pressed == true:
		var line = "rot"
		match r_option_button.selected:
			0:#- Relative
				line += "R("
			1:#- Absolute
				line += "A("
		
		var x1 = ""
		var x2 = ""
		x1 = str(rx_spin_box.value)
		x1 += ".0" if not "." in x1 else ""
		if rx_range_button.pressed == true:
			x2 = "/" + str(rx_spin_box_2.value)
			x2 += ".0" if not "." in x2 else ""
		
		var y1 = ""
		var y2 = ""
		y1 = str(ry_spin_box.value)
		y1 += ".0" if not "." in y1 else ""
		if ry_range_button.pressed == true:
			y2 = "/" + str(ry_spin_box_2.value)
			y2 += ".0" if not "." in y2 else ""
		
		var z1 = ""
		var z2 = ""
		z1 = str(rz_spin_box.value)
		z1 += ".0" if not "." in z1 else ""
		if rz_range_button.pressed == true:
			z2 = "/" + str(rz_spin_box_2.value)
			z2 += ".0" if not "." in z2 else ""
		
		line += x1 + x2 + "," + y1 + y2 + "," + z1 + z2 + ")"
		results.append(line)
	
	#- Scale
	if sca_check_button.pressed == true:
		var line = "scale("
		
		var x1 = ""
		var x2 = ""
		x1 = str(s_min_spin_box.value)
		x1 += ".0" if not "." in x1 else ""
		if s_range_button.pressed == true:
			x2 = "/" + str(s_max_spin_box.value)
			x2 += ".0" if not "." in x2 else ""
		
		line += x1 + x2 + ")"
		results.append(line)
	
	return results

func pos_toggled(state:bool):
	pos_v_box_container.visible = state
	pass

func rot_toggled(state:bool):
	rot_v_box_container.visible = state
	pass

func sca_toggled(state:bool):
	sca_v_box_container.visible = state
	pass

func px_toggled(state:bool):
	if state == false:
		px_range_button.icon = Functions.load_image(locked)
		px_spin_box_2.editable = false
	else: 
		px_range_button.icon = Functions.load_image(unlocked)
		px_spin_box_2.editable = true
	pass

func py_toggled(state:bool):
	if state == false:
		py_range_button.icon = Functions.load_image(locked)
		py_spin_box_2.editable = false
	else: 
		py_range_button.icon = Functions.load_image(unlocked)
		py_spin_box_2.editable = true
	pass

func pz_toggled(state:bool):
	if state == false:
		pz_range_button.icon = Functions.load_image(locked)
		pz_spin_box_2.editable = false
	else: 
		pz_range_button.icon = Functions.load_image(unlocked)
		pz_spin_box_2.editable = true
	pass

func rx_toggled(state:bool):
	if state == false:
		rx_range_button.icon = Functions.load_image(locked)
		rx_spin_box_2.editable = false
	else: 
		rx_range_button.icon = Functions.load_image(unlocked)
		rx_spin_box_2.editable = true
	pass

func ry_toggled(state:bool):
	if state == false:
		ry_range_button.icon = Functions.load_image(locked)
		ry_spin_box_2.editable = false
	else: 
		ry_range_button.icon = Functions.load_image(unlocked)
		ry_spin_box_2.editable = true
	pass

func rz_toggled(state:bool):
	if state == false:
		rz_range_button.icon = Functions.load_image(locked)
		rz_spin_box_2.editable = false
	else: 
		rz_range_button.icon = Functions.load_image(unlocked)
		rz_spin_box_2.editable = true
	pass

func s_toggled(state:bool):
	if state == false:
		s_range_button.icon = Functions.load_image(locked)
		s_max_spin_box.editable = false
	else: 
		s_range_button.icon = Functions.load_image(unlocked)
		s_max_spin_box.editable = true
	pass
