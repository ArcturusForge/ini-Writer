extends PanelContainer

onready var id_panel = $HBoxContainer/IdPanel

func put(line:String)->void:
	id_panel.put(line)
	

func grab()->String:
	return id_panel.grab()
	

func _on_Button_pressed():
	self.queue_free()
	
