extends Control

#-- Constants
const my_id = "console"

#-- Scene Refs
var rich_text_label:RichTextLabel

func jump_start():
	Globals.set_manager(my_id, self)
	rich_text_label = $"../../Interface/VBoxContainer/MainDisplay/ConsoleColor/Console/ConsoleContainer/ConsoleColor/ConsoleOutput"
	pass

func generate(msg:String, colorHex:String):
	msg = "[color="+ colorHex +"]" + msg + "[/color]" + "		\n"
	rich_text_label.bbcode_text += msg
	pass

func post(msg:String):
	generate(msg, Globals.grey)
	pass

func posterr(msg:String):
	generate(msg, Globals.red)
	pass

func postwrn(msg:String):
	generate(msg, Globals.yellow)
	pass

func _on_ClearButton_pressed():
	rich_text_label.bbcode_text = ""
	pass

func _on_RichTextLabel_meta_clicked(meta):
	Functions.open_link(meta)
	pass
