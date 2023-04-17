extends Control

#-- Constants
const my_id = "console"

#-- Scene Refs
onready var rich_text_label:RichTextLabel = $"../../Interface/VBoxContainer/MainDisplay/ConsoleColor/Console/ConsoleContainer/ConsoleColor/ConsoleOutput"

#-- Dynamic Vars
var scroller:VScrollBar

func jump_start():
	Globals.set_manager(my_id, self)
	scroller = rich_text_label.get_v_scroll()
	scroller.connect("changed", self, "scroll_to_bottom")
	pass

func scroll_to_bottom():
	if scroller.value != scroller.max_value:
		scroller.value = scroller.max_value
	pass

func generate(msg:String, colorHex:String):
	msg = "[color="+ colorHex +"]" + msg + "[/color]"
	if rich_text_label.text.length() > 0:
		rich_text_label.bbcode_text += "\n" + msg
	else:
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
