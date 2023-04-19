extends Control

#-- Constants
const my_id = "edit"

#-- Prefabs
var edit_selector_prefab = preload("res://Internal/Prefabs/Interfaces/EditsListDragElement.tscn")
var edit_add_prefab = preload("res://Internal/Prefabs/Interfaces/EditsEntryAddElement.tscn")

#-- Scene Refs
onready var edits_list = $"../../Interface/VBoxContainer/MainDisplay/EditRawWindow/EditorWindow/SelectorEditorWindow/VerticalColor/SelectorContainer/EditsList"
onready var edit_display = $"../../Interface/VBoxContainer/MainDisplay/EditRawWindow/EditorWindow/SelectorEditorWindow/VerticalColor2/EditorContainer/EditDisplay"

#-- Dynamic Refs
var oMan

func jump_start():
	Globals.set_manager(my_id, self)
	oMan = Globals.get_manager("overall")
	pass

#--- Reads the session file to get the latest changes and display them.
func update_editor(nameArray):
	#- Clear existing elements.
	for child in edits_list.get_children():
		child.queue_free()
	
	#- Generate new elements.
	for i in nameArray.size():
		var editName = nameArray[i]
		var button = edit_selector_prefab.instance()
		edits_list.add_child(button)
		Functions.wait_frame()
		button.init_selector(editName, i)
	
	#- Generate the add new edit button.
	var addBtn = edit_add_prefab.instance()
	edits_list.add_child(addBtn)
	#- Wait a frame for button to init.
	Functions.wait_frame()
	#- Assign data.
	var addPop = addBtn.add_button.get_popup()
	addPop.connect("index_pressed", self, "handle_option_select")
	addPop.add_item()
	pass

func alter_records():
	var oMan = Globals.get_manager("overall")
	var raw = oMan.activeInterpreter.interp_to_raw()
	Session.data.raw = raw
	oMan.repaint_raw_editor()
	pass

func handle_option_select(index):
	pass
