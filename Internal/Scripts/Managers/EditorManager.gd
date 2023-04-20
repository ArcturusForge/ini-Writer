extends Control

#-- Constants
const my_id = "edit"

#-- Prefabs
var edit_selector_prefab = preload("res://Internal/Prefabs/Interfaces/EditsListDragElement.tscn")
var edit_add_prefab = preload("res://Internal/Prefabs/Interfaces/EditsEntryAddElement.tscn")

#-- Scene Refs
onready var edits_list = $"../../Interface/VBoxContainer/MainDisplay/EditRawWindow/EditorWindow/SelectorEditorWindow/VerticalColor/SelectorContainer/EditsList"
onready var editor_container = $"../../Interface/VBoxContainer/MainDisplay/EditRawWindow/EditorWindow/SelectorEditorWindow/VerticalColor2/EditorContainer"
onready var editor_parent = $"../../Interface/VBoxContainer/MainDisplay/EditRawWindow/EditorWindow/SelectorEditorWindow/VerticalColor2"

#-- Dynamic Refs
var oMan
var currentEditor
var selectors = []
var addBtnIndex:int

func jump_start():
	Globals.set_manager(my_id, self)
	oMan = Globals.get_manager("overall")
	pass

func _ready():
	create_add_button(0)
	pass

#--- Reads the session file to get the latest changes and display them.
func update_editor(nameArray):
	#- Clear existing elements.
	for child in edits_list.get_children():
		child.queue_free()
	selectors = []
	
	#- Generate new elements.
	for i in nameArray.size():
		var editName = nameArray[i]
		var button = edit_selector_prefab.instance()
		edits_list.add_child(button)
		button.init_selector(editName, i, self)
		selectors.append(button)
	
	#- Generate the add new edit button.
	create_add_button(nameArray.size())
	editor_parent.visible = false
	pass

func create_add_button(index):
	#- Generate the add new edit button.
	var addEditParent = edit_add_prefab.instance()
	edits_list.add_child(addEditParent)
	Functions.wait_frame()
	#- Assign data.
	addBtnIndex = index
	var addBtn = addEditParent.get_button()
	addBtn.connect("pressed", self, "on_create_select")
	pass

func alter_records():
	var raw = oMan.activeInterpreter.interp_to_raw(Session.data.interp)
	Session.data.raw = raw
	oMan.repaint_editors()
	pass

#--- Called when the add new edit button is pressed.
func on_create_select():
	#- Clear current editor.
	if not currentEditor == null:
		currentEditor.queue_free()
	
	currentEditor = load(oMan.extension.editor).instance()
	editor_container.add_child(currentEditor)
	currentEditor.init_driver(addBtnIndex, self, oMan.activeInterpreter)
	currentEditor.create_new()
	editor_parent.visible = true
	pass

#--- Called when selecting an existing edit from the edits list.
func on_edit_select(index):
	for i in range(selectors.size()):
		if i == index:
			continue
		selectors[i].edit_button.pressed = false
	
	#- Clear current editor.
	if not currentEditor == null:
		currentEditor.queue_free()
	
	currentEditor = load(oMan.extension.editor).instance()
	editor_container.add_child(currentEditor)
	currentEditor.init_driver(index, self, oMan.activeInterpreter)
	currentEditor.modify_existing(Session.data.interp)
	editor_parent.visible = true
	pass

#--- Called by the edit display driver to notify the manager to apply changes.
func alert_to_edits():
	currentEditor.apply_edit(Session.data.interp)
	alter_records()
	pass

func cancel_create():
	editor_parent.visible = false
	pass

func delete_edit(index):
	oMan.activeInterpreter.delete_edit(index, Session.data.interp)
	alter_records()
	pass
