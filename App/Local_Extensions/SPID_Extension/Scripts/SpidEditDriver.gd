extends VBoxContainer

#-- Scene Refs
onready var type_select:OptionButton = $TypePanel/VBoxContainer/TypeSelect
onready var name_edit:LineEdit = $CommentPanel/VBoxContainer/NameContainer/NameEdit
onready var comment_edit:LineEdit = $CommentPanel/VBoxContainer/CommentEdit
onready var source_select:OptionButton = $SourcePanel/VBoxContainer/SourceSelect
onready var id_edit:LineEdit = $SourcePanel/VBoxContainer/IdEdit
onready var source_edit:LineEdit = $SourcePanel/VBoxContainer/SourceContainer/SourceEdit

onready var m_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/TraitsContainer/MCheckBox
onready var m_exclude_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/ExcludesContainer/MExcludeCheckBox

onready var f_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/TraitsContainer/FCheckBox
onready var f_exclude_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/ExcludesContainer/FExcludeCheckBox

onready var u_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/TraitsContainer/UCheckBox
onready var u_exclude_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/ExcludesContainer/UExcludeCheckBox

onready var c_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/TraitsContainer/CCheckBox
onready var c_exclude_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/ExcludesContainer/CExcludeCheckBox

onready var amount_spin_box:SpinBox = $AmountPanel/VBoxContainer/AmountSpinBox
onready var index_spin_box:SpinBox = $IndexPanel/VBoxContainer/IndexSpinBox
onready var chance_spin_box:SpinBox = $ChancePanel/VBoxContainer/ChanceSpinBox

#-- Misc Refs
onready var name_container = $CommentPanel/VBoxContainer/NameContainer
onready var source_container = $SourcePanel/VBoxContainer/SourceContainer

onready var string_filter_container = $StringFiltersPanel/VBoxContainer/StringFilterContainer
onready var string_add_element:Button = $StringFiltersPanel/VBoxContainer/StringAddElement/AddButton

onready var form_filter_container = $FormFiltersPanel/VBoxContainer/FormFilterContainer
onready var form_add_element:Button = $FormFiltersPanel/VBoxContainer/FormAddElement/AddButton

onready var level_filter_container = $LevelFiltersPanel/VBoxContainer/LevelFilterContainer
onready var level_add_element:Button = $LevelFiltersPanel/VBoxContainer/LevelAddElement/AddButton

#-- Field Panels
onready var type_panel = $TypePanel
onready var comment_panel = $CommentPanel
onready var source_panel = $SourcePanel
onready var string_filters_panel = $StringFiltersPanel
onready var form_filters_panel = $FormFiltersPanel
onready var level_filters_panel = $LevelFiltersPanel
onready var trait_filters_panel = $TraitFiltersPanel
onready var amount_panel = $AmountPanel
onready var index_panel = $IndexPanel
onready var chance_panel = $ChancePanel

#-- Dynamic Vars
var workingIndex:int = -1 #- Points towards the index for this ini edit.
var system #- Points towards the editor window manager.

#--- Called by system to initialize the driver.
func init_driver(workingIndex, system):
	self.workingIndex = workingIndex
	self.system = system
	type_select.connect("item_selected", self, "handle_type")
	pass

#--- Called by system to modify an existing ini edit.
func modify_existing(interp):
	
	pass

#--- Called by system to write a new ini edit.
func create_new():
	pass

#--- Call to notify the system of changes made.
func notify_system():
	system.alert_to_edits()
	pass

#--- Called by system to apply changes to the ini edit.
func apply_edit(interp): #- [Called on every change by the user]
	pass

#--- Determines which fields should be active.
func handle_type(selectedIndex:int):
	match selectedIndex:
		-1:#- Comment
			name_container.visible = false
			toggle_visibility()
		2:#- Item
			name_container.visible = true
			toggle_visibility(true, true, true, true, true, true, false, true)
		5:#- Package
			name_container.visible = true
			toggle_visibility(true, true, true, true, true, false, true, true)
		0,1,3,4,6,7,8,9,10,11:#- Everything else
			name_container.visible = true
			toggle_visibility(true, true, true, true, true, false, false, true)
	pass

#--- Helper utility for enabling field panels.
func toggle_visibility(source:bool=true, string:bool=false, form:bool=false, level:bool=false, trait:bool=false, amount:bool=false, index:bool=false, chance:bool=false):
	source_panel.visible = source
	string_filters_panel.visible = string
	form_filters_panel.visible = form
	level_filters_panel.visible = level
	trait_filters_panel.visible = trait
	amount_panel.visible = amount
	index_panel.visible = index
	chance_panel.visible = chance
	pass


