extends Control

func _ready():
	self.connect("gui_input", self, "handle_input")
	pass

func handle_input(event: InputEvent):
	if event.is_pressed() && event.button_index == BUTTON_LEFT:
		var message = "------------\n"
		message += self.hint_tooltip
		message += "\n------------"
		Globals.get_manager("console").post(message)
	pass
