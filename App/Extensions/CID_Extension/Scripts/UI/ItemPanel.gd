extends Node

#-- Primary Vars
onready var idPanel1:VBoxContainer = $NodeContainer/IdPanel
onready var itemAmount1:SpinBox = $NodeContainer/QuantityPanel/SpinBox
onready var quantityPanel1:VBoxContainer = $NodeContainer/QuantityPanel

#-- Replacment Vars
onready var replacePanel:VBoxContainer = $NodeContainer/ReplacementPanel
onready var idPanel2:VBoxContainer = $NodeContainer/ReplacementPanel/IdPanel2
onready var itemAmount2:SpinBox = $NodeContainer/ReplacementPanel/QuantityPanel2/SpinBox

#-- Dynamic Vars
var uiType = 0


func setup(type:int)->void:
	uiType = type
	match type:
		1,2:#- Add/Remove
			replacePanel.visible = false
			quantityPanel1.visible = true
		3:#- RemoveAll
			replacePanel.visible = false
			quantityPanel1.visible = false
		4:#- Replace
			replacePanel.visible = true
			quantityPanel1.visible = true
		5:#- ReplaceAll
			replacePanel.visible = true
			quantityPanel1.visible = false
	

func put(line:="")->void:
	if line == "":
		idPanel1.put("")
		idPanel2.put("")
		return
	
	#- Parse line into datapoints.
	var dps = []
	if "^" in line: #- Is Replacement Variant
		var rep = line.split("^")
		if "|" in rep[0]:#- Is Replace
			dps.append({
				"type":0, #- (0)DISTR, (1)Identifier
				"dp":rep[0]
			})
			dps.append({
				"type":0, #- (0)DISTR, (1)Identifier
				"dp":rep[1]
			})
		else: #- Is ReplaceAll
			dps.append({
				"type":1, #- (0)DISTR, (1)Identifier
				"dp":rep[0]
			})
			dps.append({
				"type":0, #- (0)DISTR, (1)Identifier
				"dp":rep[1]
			})
	elif "|" in line: #- Is Add/Remove
		if line[0] == "-":
			line.erase(0, 1)
		dps.append({
				"type":0, #- (0)DISTR, (1)Identifier
				"dp":line
			})
	else: #- Is RemoveAll
		if line[0] == "-":
			line.erase(0, 1)
		dps.append({
				"type":1, #- (0)DISTR, (1)Identifier
				"dp":line
			})
	
	#- Assign text to ui
	if dps.size() > 0:
		if dps[0].type == 0:
			var vals = dps[0].dp.split("|")
			idPanel1.put(vals[0])
			itemAmount1.value = int(vals[1])
		elif dps[0].type == 1:
			idPanel1.put(dps[0].dp)
		
		if dps.size() >= 2:
			if dps[1].type == 0:
				var vals = dps[1].dp.split("|")
				idPanel2.put(vals[0])
				itemAmount2.value = int(vals[1])
			elif dps[1].type == 1:
				idPanel2.put(dps[1].dp)
	

func grab()->String:
	var t = ""
	match uiType:
		1:#- Add
			t = idPanel1.grab() + "|" + str(itemAmount1.value)
		2:#- Remove
			t = "-" + idPanel1.grab() + "|" + str(itemAmount1.value)
		3:#- RemoveAll
			t = "-" + idPanel1.grab()
		4:#- Replace
			t = idPanel1.grab() + "|" + str(itemAmount1.value) + "^" + idPanel2.grab() + "|" + str(itemAmount2.value)
		5:#- ReplaceAll
			t = idPanel1.grab() + "^" + idPanel2.grab() + "|" + str(itemAmount2.value)
	return t
	
