extends VBoxContainer

#-- Scene Refs
onready var type_select = $TypePanel/VBoxContainer/TypeSelect
onready var comment_panel = $CommentPanel
onready var name_container = $CommentPanel/VBoxContainer/NameContainer
onready var restrictions_panel = $RestrictionsPanel
onready var source_panel = $SourcePanel
onready var targets_panel = $TargetsPanel
onready var transform_panel = $TransformPanel
onready var chance_panel = $ChancePanel

#-- Dynamic Vars
var workingIndex:int = -1 #- Points towards the index for this ini edit.
var system #- Points towards the editor window manager.
var interpreter #- The interpreter script from this particular extension.
var isNew = false

#--- Called by system to initialize the driver.
func init_driver(workingIndex, system, interpreter):
	self.workingIndex = workingIndex
	self.system = system
	self.interpreter = interpreter
	type_select.connect("item_selected", self, "handle_toggle")
	pass

#--- Called by system to modify an existing ini edit.
func modify_existing(interp):
	isNew = false
	draw_panels(interp.edits[workingIndex])
	pass

#--- Called by system to write a new ini edit.
func create_new():
	isNew = true
	draw_panels(interpreter.new_edit())
	pass

#--- Call this to cancel editing.
func cancel_edit():
	system.cancel_create()
	pass

#--- Call this to notify the system of changes made.
func notify_system():
	system.alert_to_edits()
	pass

#--- Called by system to apply changes to the ini edit.
func apply_edit(interp):
	var edit = interpreter.new_edit()
	
	edit.editType = type_select.selected - 1
	
	var comDat = comment_panel.get_data()
	edit.notation.name = comDat[0]
	edit.notation.comment = comDat[1]
	
	var resDat = restrictions_panel.get_data()
	edit.restrictions = resDat
	
	var souDat = source_panel.get_data()
	edit.target = souDat[0]
	
	var tarDat = targets_panel.get_data()
	edit.replacements = tarDat
	
	var traDat = transform_panel.get_data()
	for tran in traDat:
		if "pos" in tran:
			edit.transform.position = tran
		elif "rot" in tran:
			edit.transform.rotation = tran
		elif "scale" in tran:
			edit.transform.scale = tran
	
	var chaDat = chance_panel.get_data()
	edit.chance = chaDat[0] if chaDat.size() > 0 else ""
	
	#- Apply to interp
	if not isNew:
		var ogEdit = interp.edits[workingIndex]
		edit.notation.newlines = ogEdit.notation.newlines
		edit.notation.lineStart = ogEdit.notation.lineStart
		edit.notation.lineEnd = ogEdit.notation.lineEnd
		
		if ogEdit.notation.comment == "" && not edit.notation.comment == "" && not edit.editType == -1:
			edit.notation.lineStart += 1
			edit.notation.lineEnd -= 1
		elif not ogEdit.notation.comment == "" && edit.notation.comment == "" && not edit.editType == -1:
			edit.notation.lineStart -= 1
			edit.notation.lineEnd += 1
		
		interp.edits[workingIndex] = edit
		Globals.get_manager("console").post("Modified (" + interpreter.get_edit_name(interp, workingIndex) + ")")
	else:
		var startNum = 1
		var endNum = 1
		if interp.edits.size() > 0:
			var prevEdit = interp.edits[interp.edits.size()-1] 
			startNum = prevEdit.notation.lineEnd + prevEdit.notation.newlines
			endNum = startNum
			if prevEdit.editType != edit.editType || !interpreter.array_match(prevEdit.restrictions, edit.restrictions):
				endNum += 1
		else:
			endNum += 1
		
		if edit.notation.comment != "":
			endNum += 1
		
		edit.notation.lineStart = startNum
		edit.notation.lineEnd = endNum
		interp.edits.append(edit)
		Globals.get_manager("console").post("Created (" + interpreter.get_edit_name(interp, interp.edits.size()-1) + ")")
	pass

#--- CUSTOM: Handles drawing the ui.
func draw_panels(edit):
	type_select.select(edit.editType + 1)
	
	comment_panel.set_data(edit)
	restrictions_panel.set_data(edit)
	source_panel.set_data(edit)
	targets_panel.set_data(edit)
	transform_panel.set_data(edit)
	chance_panel.set_data(edit)
	
	handle_toggle(edit.editType + 1) #- Plus 1 because function is designed for MenuOption indexing.
	pass

#--- CUSTOM: automates panel toggling.
func handle_toggle(index:int):
	match index:
		0:
			toggle_panels(false, false, false, false, false, false)
		1,2:
			toggle_panels(true, true, true, true, true, true)
		3:
			toggle_panels(true, true, true, false, true, true)

#--- CUSTOM: Toggles ui panels.
func toggle_panels(a:bool, b:bool, c:bool, d:bool, e:bool, f:bool):
	name_container.visible = a
	restrictions_panel.visible = b
	source_panel.visible = c
	targets_panel.visible = d
	transform_panel.visible = e
	chance_panel.visible = f
	pass

func _on_ApplyButton_pressed():
	notify_system()
	pass

func _on_CancelButton_pressed():
	cancel_edit()
	pass
