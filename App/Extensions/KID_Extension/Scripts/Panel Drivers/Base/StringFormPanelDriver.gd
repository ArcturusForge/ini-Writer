extends PanelContainer

#-- Scene Refs
onready var string_filter_container = $VBoxContainer/VBoxContainer/StringFilterContainer
onready var form_filter_container = $VBoxContainer/VBoxContainer2/FormFilterContainer

#-- Prefabs
var stringFilter = "res://App/Extensions/KID_Extension/Interfaces/Sub Panels/StringFilter.tscn"
var formFilter = "res://App/Extensions/KID_Extension/Interfaces/Sub Panels/FormFilter.tscn"

#--- SYSTEM: Reset ui to init user state.
func init():
	pass

#--- SYSTEM: Used to init the ui.
func set_data(edit):
	var sFilts = []
	var fFilts = []
	for filter in edit.stringAndFormFilters:
		if "0x" in filter || "~" in filter: #- FormID
			fFilts.append(filter)
		elif "+" in filter || "-" in filter || "/" in filter || ".nif" in filter: #- String
			sFilts.append(filter)
		else: #- Probably a string or editorID
			sFilts.append(filter)
	
	for sfil in sFilts:
		var filter = Functions.get_from_prefab(stringFilter)
		string_filter_container.add_child(filter)
		filter.add_existing(sfil)
	
	for ffil in fFilts:
		var filter = Functions.get_from_prefab(formFilter)
		form_filter_container.add_child(filter)
		filter.add_existing(ffil)
	pass

#--- SYSTEM: Used to compile the data into an edit.
#--- [edit] is an instance reference so changes will apply for all ref holders.
func apply_data(edit):
	for filter in string_filter_container.get_children():
		edit.stringAndFormFilters.append(filter.compile_data())
	
	for filter in form_filter_container.get_children():
		edit.stringAndFormFilters.append(filter.compile_data())
	pass

func _on_StringAddButton_pressed():
	var filter = Functions.get_from_prefab(stringFilter)
	string_filter_container.add_child(filter)
	filter.add_node()
	pass

func _on_FormAddButton_pressed():
	var filter = Functions.get_from_prefab(formFilter)
	form_filter_container.add_child(filter)
	filter.add_node()
	pass
