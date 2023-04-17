extends Control

#-- Constants
const my_id = "raw"

#-- Scene Refs
onready var text_edit:TextEdit = $"../../Interface/VBoxContainer/MainDisplay/EditRawWindow/RawWindow/TextEdit"

func jump_start():
	Globals.set_manager(my_id, self)
	text_edit.clear_colors()
	text_edit.clear_undo_history()
	pass

#--- Reads the session file to get the latest changes and display them.
func update_editor():
	pass
