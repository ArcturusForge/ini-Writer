extends PanelContainer

#-- Scene Refs
onready var delete_button = $HBoxContainer/DeleteButton
onready var edit_button = $HBoxContainer/EditButton

#-- Dynamic Vars
var origIndex:int

func init_selector(text:String, index:int):
	edit_button.text = text
	origIndex = index
	pass

#--- Called to open the editor for a SPID edit.
func _on_EditButton_pressed():
	pass # Replace with function body.

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
