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

func put(line:String, type:int)->void:
	setup(type)
	if "^" in line: #- Is Replacement
		var rep = line.split("^")
		if "|" in rep[0]:#- Is Normal Replace
			pass
		else: #- Is ReplaceAll
			pass
	

func grab()->String:
	var t = ""
	return t
	

func setup(type:int)->void:
	uiType = type
	match type:
		1,2:#- Add/Remove
			replacePanel.visible = false
			quantityPanel1.visible = true
		3:#- RemoveAll
			replacePanel.visible = false
			quantityPanel1.visible = true
		4:#- Replace
			replacePanel.visible = true
			quantityPanel1.visible = true
		5:#- ReplaceAll
			replacePanel.visible = true
			quantityPanel1.visible = false
	
