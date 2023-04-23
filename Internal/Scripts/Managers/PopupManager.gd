extends Control

#-- Constants
const my_id = "popup"

#- Scripts
var popupDataScript = preload("res://Internal/Scripts/Generics/PopupData.gd")

#-- Dynamic Vars
var popupRegistries = {}

#--- Functions
func jump_start():
	Globals.set_manager(my_id, self)
	pass

func register_popup(name, popup):
	if not popupRegistries.has(name):
		var pData = popupDataScript.new()
		pData.construct(popup)
		popupRegistries[name] = pData
	pass

func remove_popup(name):
	if popupRegistries.has(name):
		popupRegistries.erase(name)
	pass

func get_popup_data(name):
	if popupRegistries.has(name):
		return popupRegistries[name]
	return null
