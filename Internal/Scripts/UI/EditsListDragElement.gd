extends PanelContainer

#-- Scene Refs
onready var delete_button:MenuButton = $HBoxContainer/DeleteButton
onready var edit_button:Button = $HBoxContainer/EditButton

#-- Dynamic Vars
var origIndex:int
var editorManager

func init_selector(text:String, index:int, editorManager):
	edit_button.text = text
	origIndex = index
	self.editorManager = editorManager
	delete_button.get_popup().connect("index_pressed", self, "handle_delete")
	pass

#--- Called to open the editor for a SPID edit.
func _on_EditButton_pressed():
	if edit_button.pressed:
		editorManager.on_edit_select(origIndex)
	else:
		editorManager.editor_parent.visible = false
	pass

func get_drag_data(position):
	var data = {
		"index":origIndex
	}
	set_drag_preview(self.duplicate())
	return data

func can_drop_data(position, data):
	if data.index == origIndex:
		return false
	return true

func drop_data(position, data):
	var oMan = Globals.get_manager("overall")
	oMan.move_edit_selector(data.index, origIndex)
	pass

func handle_delete(index):
	if index == 1:
		#- Delete
		editorManager.delete_edit(origIndex)
	pass
