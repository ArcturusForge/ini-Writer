extends VBoxContainer

#-- Selector
onready var typeSelector:OptionButton = $TypePanel/VBoxContainer/OptionButton

#-- Panel Vars
onready var commentPanel = $CommentPanel
onready var containerPanel = $ContainerPanel
onready var recipientPanel = $RecipientPanel

#-- Comment Panel Vars
onready var nameContainer = $CommentPanel/VBoxContainer/NameContainer
onready var nameEdit:LineEdit = $CommentPanel/VBoxContainer/NameContainer/NameEdit
onready var commentEdit:LineEdit = $CommentPanel/VBoxContainer/CommentEdit
onready var newlineSpinbox:SpinBox = $CommentPanel/VBoxContainer/SpinBox
#-- Container Panel Vars
onready var idPanel = $ContainerPanel/VBoxContainer/IdPanel
#-- Recipient Panel Vars
onready var itemPanel = $RecipientPanel/VBoxContainer/ItemPanel

#-- Dynamic Vars
var workingIndex:int = -1 #- Points towards the index for this ini edit.
var system #- Points towards the editor window manager.
var interpreter #- The interpreter script from this particular extension.

#--- Called by system to initialize the driver.
func init_driver(workingIndex, system, interpreter):
	self.workingIndex = workingIndex
	self.system = system
	self.interpreter = interpreter
	pass

#--- Called by system to modify an existing ini edit.
func modify_existing(interp):
	prepare_edit(interp.edits[workingIndex])
	pass

#--- Called by system to write a new ini edit.
func create_new():
	workingIndex = -1
	prepare_edit(interpreter.new_edit())
	pass

#--- Call this to notify the system of changes made.
func notify_system():
	system.alert_to_edits()
	pass

#--- Call this to cancel editing.
func cancel_edit():
	system.cancel_create()
	pass

#--- Called by system to apply changes to the ini edit.
func apply_edit(interp):
	var edit = interpreter.new_edit()
	edit.type = typeSelector.selected
	edit.notes.name = nameEdit.text
	edit.notes.comment = commentEdit.text
	edit.notes.newlines = newlineSpinbox.value
	edit.container = idPanel.grab()
	edit.target = itemPanel.grab()
	
	if workingIndex != -1:
		interp.edits[workingIndex] = edit
	else:
		interp.edits.append(edit)
	

#--------------------Begin Custom----------------------

func _on_OptionButton_item_selected(index):
	match index:
		0:#- Comment
			nameContainer.visible = false
			commentPanel.visible = true
			containerPanel.visible = false
			recipientPanel.visible = false
		1,2,3,4,5:#- Add/Remove/RemoveAll/Replace/ReplaceAll
			nameContainer.visible = true
			commentPanel.visible = true
			containerPanel.visible = true
			recipientPanel.visible = true
			itemPanel.setup(index)
	

func _on_ApplyButton_pressed():
	notify_system()
	

func _on_CancelButton_pressed():
	cancel_edit()
	

func prepare_edit(editData)->void:
	typeSelector.select(editData.type)
	_on_OptionButton_item_selected(editData.type)
	nameEdit.text = editData.notes.name
	commentEdit.text = editData.notes.comment
	newlineSpinbox.value = editData.notes.newlines
	idPanel.put(editData.container)
	itemPanel.put(editData.target)
	
