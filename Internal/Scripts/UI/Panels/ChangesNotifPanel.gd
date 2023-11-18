extends Control

var changePath = "res://App/update.txt"
onready var rich_text_label = $VBoxContainer/HBoxContainer/RichTextLabel

func _ready():
	self.show()
	
	var f = File.new()
	f.open(changePath, File.READ_WRITE)
	var t = f.get_as_text()
	
	if t.begins_with("[0]"):
		if Functions.is_app():
			t.erase(0, 3)
			var v = t
			t = "[1]" + t
			rich_text_label.bbcode_text = v
		else:
			rich_text_label.bbcode_text = t
	elif t.begins_with("[1]") || t == "":
		self.hide()
	
	f.store_string(t)
	f.close()
	

func _on_Close_pressed():
	self.hide()
	
