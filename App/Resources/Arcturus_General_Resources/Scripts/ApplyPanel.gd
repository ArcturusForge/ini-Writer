extends PanelContainer

signal on_apply
signal on_cancel

func _on_ApplyButton_pressed():
	self.emit_signal("on_apply")
	

func _on_CancelButton_pressed():
	self.emit_signal("on_cancel")
	
