extends VBoxContainer

#-- Scene Refs
onready var type_select:OptionButton = $TypePanel/VBoxContainer/TypeSelect
onready var name_edit:LineEdit = $CommentPanel/VBoxContainer/NameContainer/NameEdit
onready var comment_edit:LineEdit = $CommentPanel/VBoxContainer/CommentEdit
onready var source_select:OptionButton = $SourcePanel/VBoxContainer/SourceSelect
onready var id_edit:LineEdit = $SourcePanel/VBoxContainer/IdEdit
onready var source_edit:LineEdit = $SourcePanel/VBoxContainer/SourceContainer/SourceEdit

onready var m_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/TraitsContainer/MCheckBox
onready var f_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/ExcludesContainer/FCheckBox

onready var u_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/TraitsContainer/UCheckBox
onready var u_exclude_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/ExcludesContainer/UExcludeCheckBox

onready var s_check_box = $TraitFiltersPanel/VBoxContainer/OptionsContainer/TraitsContainer/SCheckBox
onready var s_exclude_check_box = $TraitFiltersPanel/VBoxContainer/OptionsContainer/ExcludesContainer/SExcludeCheckBox

onready var c_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/TraitsContainer/CCheckBox
onready var c_exclude_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/ExcludesContainer/CExcludeCheckBox

onready var amount_spin_box:SpinBox = $AmountPanel/VBoxContainer/AmountSpinBox
onready var index_spin_box:SpinBox = $IndexPanel/VBoxContainer/IndexSpinBox
onready var chance_spin_box:SpinBox = $ChancePanel/VBoxContainer/ChanceSpinBox

#-- Misc Refs
onready var name_container = $CommentPanel/VBoxContainer/NameContainer
onready var source_container = $SourcePanel/VBoxContainer/SourceContainer

onready var string_filter_container = $StringFiltersPanel/VBoxContainer/StringFilterContainer
onready var form_filter_container = $FormFiltersPanel/VBoxContainer/FormFilterContainer
onready var level_filter_container = $LevelFiltersPanel/VBoxContainer/LevelFilterContainer

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
var interpreter
var isNew = false

#-- Prefabs
var string_filter_prefab = "res://App/Extensions/SPID_Extension/Interfaces/Filters/StringFilter.tscn"
var form_filter_prefab = "res://App/Extensions/SPID_Extension/Interfaces/Filters/FormFilter.tscn"

#--- Called by system to initialize the driver.
func init_driver(workingIndex, system, interpreter):
	self.workingIndex = workingIndex
	self.system = system
	self.interpreter = interpreter
	type_select.connect("item_selected", self, "handle_type")
	source_select.connect("item_selected", self, "handle_source")
	pass

#--- Called by system to modify an existing ini edit.
func modify_existing(interp):
	isNew = false
	var edit = interp.edits[workingIndex]
	type_select.selected = edit.type + 1
	handle_type(type_select.selected)
	generate_comment_panel(edit)
	generate_source_panel(edit)
	generate_string_panel(edit)
	generate_form_panel(edit)
	generate_level_panel(edit)
	generate_trait_panel(edit)
	generate_amount_panel(edit)
	generate_index_panel(edit)
	generate_chance_panel(edit)
	pass

#--- Called by system to write a new ini edit.
func create_new():
	isNew = true
	var edit = interpreter.create_new_edit()
	type_select.selected = edit.type + 1
	handle_type(type_select.selected)
	generate_comment_panel(edit)
	generate_source_panel(edit)
	generate_string_panel(edit)
	generate_form_panel(edit)
	generate_level_panel(edit)
	generate_trait_panel(edit)
	generate_amount_panel(edit)
	generate_index_panel(edit)
	generate_chance_panel(edit)
	pass

#--- Call to notify the system of changes made.
func notify_system():
	system.alert_to_edits()
	pass

#--- Called by system to apply changes to the ini edit.
func apply_edit(interp):
	var edit = interpreter.create_new_edit()
	
	#- Type, Name & Comment
	edit.type = type_select.selected-1
	edit.name = name_edit.text
	edit.comment = comment_edit.text
	
	#- Source
	edit.objectId.type = source_select.selected
	edit.objectId.value = id_edit.text
	edit.objectId.source = source_edit.text
	
	#- String Filters
	for filter in string_filter_container.get_children():
		edit.stringFilters.append(filter.compile_data())
	
	#_TODO: Form Filters
	#_TODO: Level Filters
	
	#- Trait Filters
	var tFils = []
	if m_check_box.pressed:
		tFils.append(["M"])
	if f_check_box.pressed:
		tFils.append(["F"])
	if u_check_box.pressed:
		if u_exclude_check_box.pressed:
			tFils.append(["-U"])
		else:
			tFils.append(["U"])
	if s_check_box.pressed:
		if s_exclude_check_box.pressed:
			tFils.append(["-S"])
		else:
			tFils.append(["S"])
	if c_check_box.pressed:
		if c_exclude_check_box.pressed:
			tFils.append(["-C"])
		else:
			tFils.append(["C"])
	edit.traitFilters = tFils
	
	#- Count Or Index
	if edit.type == 2 || edit.type == 8: #- Item, DeathItem
		edit.countOrIndex = amount_spin_box.value
	elif edit.type == 5: #- Package
		edit.countOrIndex = index_spin_box.value
	
	#- Chance
	edit.chance = chance_spin_box.value
	
	#- Apply to interp
	if not isNew:
		var newlines = interp.edits[workingIndex].newlines
		edit.newlines = newlines
		interp.edits[workingIndex] = edit
	else:
		interp.edits.append(edit)
	pass

#--- Determines which fields should be active.
func handle_type(selectedIndex:int):
	match selectedIndex-1:
		-1:#- Comment
			name_container.visible = false
			toggle_visibility(false)
		2,8:#- (2)Item, (8)DeathItem
			name_container.visible = true
			toggle_visibility(true, true, true, true, true, true, false, true)
		5:#- Package
			name_container.visible = true
			toggle_visibility(true, true, true, true, true, false, true, true)
		0,1,3,4,6,7,9,10,11:#- Everything else
			name_container.visible = true
			toggle_visibility(true, true, true, true, true, false, false, true)
	pass

#-- Determines which inputs should be active for the source panel.
func handle_source(selectedIndex:int):
	match selectedIndex:
		0:#- Auto
			source_container.visible = false
		1,2:#- Plugin
			source_container.visible = true
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

#--- Parses the edit data for the name & comment.
func generate_comment_panel(edit):
	if name_container.visible:
		name_edit.text = edit.name
	comment_edit.text = edit.comment
	pass

#--- Parses the edit data for id and source.
func generate_source_panel(edit):
	source_select.selected = edit.objectId.type
	if not edit.objectId.type == 0:
		source_edit.text = edit.objectId.source if not edit.objectId.source == "BLANK" else ""
	else:
		source_container.visible = false
	id_edit.text = edit.objectId.value
	pass

#--- Parses the edit data for string filters.
func generate_string_panel(edit):
	for filterData in edit.stringFilters:
		var filter = load(string_filter_prefab).instance()
		string_filter_container.add_child(filter)
		filter.add_existing(filterData)
	pass

#--- Parses the edit data for form filters.
func generate_form_panel(edit):
	pass

#--- Parses the edit data for level filters.
func generate_level_panel(edit):
	pass

#--- Parses the edit data for trait filters.
func generate_trait_panel(edit):
	_on_UCheckBox_pressed()
	_on_SCheckBox_pressed()
	_on_CCheckBox_pressed()
	for t in edit.traitFilters:
		match t[0].to_lower():
			"m","-m":#- Male filter.
				if "-"in t[0]:
					f_check_box.pressed = true
				else:
					m_check_box.pressed = true
			"f","-f":#- Female filter.
				if "-"in t[0]:
					m_check_box.pressed = true
				else:
					f_check_box.pressed = true
			"u","-u":#- Unique filter.
				if "-"in t[0]:
					u_exclude_check_box.pressed = true
				u_check_box.pressed = true
			"s","-s":#- Unique filter.
				if "-"in t[0]:
					s_exclude_check_box.pressed = true
				s_check_box.pressed = true
			"c","-c":#- Child filter.
				if "-"in t[0]:
					c_exclude_check_box.pressed = true
				c_check_box.pressed = true
	pass

#--- Parses the edit data for the distribution amount.
func generate_amount_panel(edit):
	if not amount_panel.visible:
		return
	amount_spin_box.value = edit.countOrIndex
	pass

#--- Parses the edit data for the package index.
func generate_index_panel(edit):
	if not index_panel.visible:
		return
	index_spin_box.value = edit.countOrIndex
	pass

#--- Parses the edit data for the distribution chance.
func generate_chance_panel(edit):
	chance_spin_box.value = edit.chance
	pass

func _on_ApplyButton_pressed():
	notify_system()
	pass

func _on_CancelButton_pressed():
	system.cancel_create()
	pass

func _on_MCheckBox_pressed():
	if m_check_box.pressed:
		f_check_box.pressed = false
	pass

func _on_FCheckBox_pressed():
	if f_check_box.pressed:
		m_check_box.pressed = false
	pass

func _on_UCheckBox_pressed():
	if u_check_box.pressed:
		u_exclude_check_box.disabled = false
	else:
		u_exclude_check_box.pressed = false
		u_exclude_check_box.disabled = true
	pass

func _on_SCheckBox_pressed():
	if s_check_box.pressed:
		s_exclude_check_box.disabled = false
	else:
		s_exclude_check_box.pressed = false
		s_exclude_check_box.disabled = true
	pass

func _on_CCheckBox_pressed():
	if c_check_box.pressed:
		c_exclude_check_box.disabled = false
	else:
		c_exclude_check_box.pressed = false
		c_exclude_check_box.disabled = true
	pass

func _on_StringAddButton_pressed():
	var filter = load(string_filter_prefab).instance()
	string_filter_container.add_child(filter)
	filter.add_node()
	pass

func _on_FormAddButton_pressed():
	var filter = load(form_filter_prefab).instance()
	form_filter_container.add_child(filter)
	filter.add_node()
	pass


func _on_LevelAddButton_pressed():
	pass # Replace with function body.
