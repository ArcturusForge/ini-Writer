extends PanelContainer

#-- Scene Refs
onready var source_select:OptionButton = $VBoxContainer/SourceSelect
onready var id_edit:LineEdit = $VBoxContainer/IdEdit
onready var source_container = $VBoxContainer/SourceContainer
onready var source_edit:LineEdit = $VBoxContainer/SourceContainer/SourceEdit

func _ready():
	source_select.connect("item_selected", self, "handle_source")
	pass

#--- Used to init the ui.
func set_data(edit):
	#- Adjust selector
	source_select.selected = edit.objectId.type
	handle_source(edit.objectId.type)
	id_edit.text = edit.objectId.value
	source_edit.text = edit.objectId.source
	pass

#--- Used to compile the data into an edit.
#--- [edit] is a instance reference so changes will apply for all viewers.
func apply_data(edit):
	edit.objectId.type = source_select.selected
	edit.objectId.value = id_edit.text
	edit.objectId.source = source_edit.text
	pass

func handle_source(selected):
	match selected:
		0:#- EditorID
			source_container.visible = false
		1,2,3:#- Esm/Esp/Skyrim & dlc
			source_container.visible = true
	pass
