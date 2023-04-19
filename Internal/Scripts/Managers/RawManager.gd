extends Control

#-- Constants
const my_id = "raw"

#-- Scene Refs
onready var text_edit:TextEdit
onready var raw_window = $"../../Interface/VBoxContainer/MainDisplay/EditRawWindow/RawWindow"

#-- Dynamic Vars
var silence = false

func jump_start():
	Globals.set_manager(my_id, self)
	text_edit = $"../../Interface/VBoxContainer/MainDisplay/EditRawWindow/RawWindow/TextEdit"
	text_edit.clear_colors()
	text_edit.clear_undo_history()
	pass

#--- Reads the session file to get the latest changes and display them.
func update_editor():
	silence = true
	text_edit.text = Session.data.raw
	silence = false
	pass

func alter_records():
	var oMan = Globals.get_manager("overall")
	var interp = oMan.activeInterpreter.raw_to_interp(text_edit.text)
	Session.data.interp = interp
	oMan.repaint_interp_editor()
	pass

func _on_TextEdit_text_changed():
	if silence:
		return
	alter_records()
	Session.data.raw = text_edit.text
	pass


func _on_RawToggle_toggled(button_pressed):
	raw_window.visible = button_pressed
	pass
