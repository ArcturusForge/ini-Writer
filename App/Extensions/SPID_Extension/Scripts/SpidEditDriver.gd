extends VBoxContainer

#-- Scene Refs
onready var type_select:OptionButton = $TypePanel/VBoxContainer/TypeSelect

onready var m_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/TraitsContainer/MCheckBox
onready var f_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/ExcludesContainer/FCheckBox
onready var u_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/TraitsContainer/UCheckBox
onready var u_exclude_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/ExcludesContainer/UExcludeCheckBox
onready var s_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/TraitsContainer/SCheckBox
onready var s_exclude_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/ExcludesContainer/SExcludeCheckBox
onready var c_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/TraitsContainer/CCheckBox
onready var c_exclude_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/ExcludesContainer/CExcludeCheckBox
onready var l_check_box:CheckBox  = $TraitFiltersPanel/VBoxContainer/OptionsContainer/TraitsContainer/LCheckBox
onready var l_exclude_check_box:CheckBox = $TraitFiltersPanel/VBoxContainer/OptionsContainer/ExcludesContainer/LExcludeCheckBox
onready var t_check_box:CheckBox  = $TraitFiltersPanel/VBoxContainer/OptionsContainer/TraitsContainer/TCheckBox
onready var t_exclude_check_box:CheckBox  = $TraitFiltersPanel/VBoxContainer/OptionsContainer/ExcludesContainer/TExcludeCheckBox

onready var amount_spin_box:SpinBox = $AmountPanel/VBoxContainer/AmountSpinBox
onready var index_spin_box:SpinBox = $IndexPanel/VBoxContainer/IndexSpinBox
onready var chance_spin_box:SpinBox = $ChancePanel/VBoxContainer/ChanceSpinBox

onready var actor_level_check_box:CheckBox = $LevelFiltersPanel/VBoxContainer/LevelFilterContainer/ActorLevelCheckBox
onready var actor_level_filter = $LevelFiltersPanel/VBoxContainer/LevelFilterContainer/ActorLevelFilter
onready var actor_range_button:Button = $LevelFiltersPanel/VBoxContainer/LevelFilterContainer/ActorLevelFilter/NodeContainer/HBoxContainer/ActorRangeButton
onready var min_actor_spin_box:SpinBox = $LevelFiltersPanel/VBoxContainer/LevelFilterContainer/ActorLevelFilter/NodeContainer/HBoxContainer/MinActorSpinBox
onready var max_actor_spin_box:SpinBox = $LevelFiltersPanel/VBoxContainer/LevelFilterContainer/ActorLevelFilter/NodeContainer/HBoxContainer/MaxActorSpinBox

onready var skill_filter_container = $LevelFiltersPanel/VBoxContainer/LevelFilterContainer/SkillFilterContainer

#-- Misc Refs
onready var string_filter_container = $StringFiltersPanel/VBoxContainer/StringFilterContainer
onready var form_filter_container = $FormFiltersPanel/VBoxContainer/FormFilterContainer
onready var level_filter_container = $LevelFiltersPanel/VBoxContainer/LevelFilterContainer

#-- Field Panels
onready var type_panel = $TypePanel
onready var comment_panel = $CommentPanel
onready var source_panel = $RecordIdPanel
onready var string_filters_panel = $StringFiltersPanel
onready var form_filters_panel = $FormFiltersPanel
onready var level_filters_panel = $LevelFiltersPanel
onready var trait_filters_panel = $TraitFiltersPanel
onready var amount_panel = $AmountPanel
onready var index_panel = $IndexPanel
onready var chance_panel = $ChancePanel
onready var apply_panel = $ApplyPanel

#-- Dynamic Vars
var workingIndex:int = -1 #- Points towards the index for this ini edit.
var system #- Points towards the editor window manager.
var interpreter
var isNew = false

#-- Prefabs
var form_filter_prefab = "res://App/Extensions/SPID_Extension/Interfaces/Filters/FormFilter.tscn"
var skill_filter_prefab = "res://App/Extensions/SPID_Extension/Interfaces/Filters/SkillLevelFilter.tscn"

#-- Graphics
onready var locked_range = preload("res://Internal/Default/Icons/lock_closed.png")
onready var unlocked_range = preload("res://Internal/Default/Icons/lock_open.png")

#--- Called by system to initialize the driver.
func init_driver(workingIndex, system, interpreter):
	self.workingIndex = workingIndex
	self.system = system
	self.interpreter = interpreter
	type_select.connect("item_selected", self, "handle_type")
	apply_panel.connect("on_apply", self, "notify_system")
	apply_panel.connect("on_cancel", self, "cancel_edit")
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

#--- Call to notify the system of changes confirmed.
func notify_system():
	system.alert_to_edits()
	pass

func cancel_edit():
	system.cancel_create()
	pass

#--- Called by system to apply changes to the ini edit.
func apply_edit(interp):
	var edit = interpreter.create_new_edit()
	
	#- Type, Name & Comment
	edit.type = type_select.selected-1
	var dat = comment_panel.grab()
	edit.misc.name = dat.name
	edit.misc.comment = dat.comment
	edit.misc.newlines = dat.newlines
	
	#- Source
	edit.objectId = source_panel.grab()
	
	#- String Filters
	edit.stringFilters = string_filters_panel.grab()
	
	#- Form Filters
	if form_filter_container.get_child_count() > 0:
		for i in range(form_filter_container.get_child_count()):
			var filter = form_filter_container.get_child(i)
			edit.formFilters += filter.compile_data()
			if i != form_filter_container.get_child_count() - 1:
				edit.formFilters += ","
	else:
		edit.formFilters = "NONE"
	
	#- Actor Level Filter
	if actor_level_check_box.pressed:
		var value = str(min_actor_spin_box.value)
		if actor_range_button.pressed:
			value += "/" + str(max_actor_spin_box.value)
		edit.levelFilters = value
	
	#- Skill Level Filter
	if skill_filter_container.get_child_count() > 0:
		if edit.levelFilters != "":
			edit.levelFilters += ","
		for i in range(skill_filter_container.get_child_count()):
			var filter = skill_filter_container.get_child(i)
			edit.levelFilters += filter.compile_data()
			if i != skill_filter_container.get_child_count() - 1:
				edit.levelFilters += ","
	else:
		edit.levelFilters = "NONE"
	
	#- Trait Filters
	var tFils = []
	if m_check_box.pressed:
		tFils.append("M")
	if f_check_box.pressed:
		tFils.append("F")
	if u_check_box.pressed:
		if u_exclude_check_box.pressed:
			tFils.append("-U")
		else:
			tFils.append("U")
	if s_check_box.pressed:
		if s_exclude_check_box.pressed:
			tFils.append("-S")
		else:
			tFils.append("S")
	if c_check_box.pressed:
		if c_exclude_check_box.pressed:
			tFils.append("-C")
		else:
			tFils.append("C")
	if l_check_box.pressed:
		if l_exclude_check_box.pressed:
			tFils.append("-L")
		else:
			tFils.append("L")
	if t_check_box.pressed:
		if t_exclude_check_box.pressed:
			tFils.append("-T")
		else:
			tFils.append("T")
	var traits:String
	if tFils.size() > 0:
		for i in range(tFils.size()):
			traits += tFils[i]
			if i < tFils.size() - 1:
				traits += "/"
	else:
		traits = "NONE"
	edit.traitFilters = traits
	
	#- Count Or Index
	if edit.type == 2 || edit.type == 8: #- Item, DeathItem
		edit.countOrIndex = amount_spin_box.value
	elif edit.type == 5: #- Package
		edit.countOrIndex = index_spin_box.value
	
	#- Chance
	edit.chance = chance_spin_box.value
	
	#- Apply to interp
	if not isNew:
		interp.edits[workingIndex] = edit
		Console.post("Modified (" + interpreter.get_edit_name(interp, workingIndex, false) + ")")
	else:
		interp.edits.append(edit)
		Console.post("Created (" + interpreter.get_edit_name(interp, interp.edits.size()-1, false) + ")")
	pass

#--- Determines which fields should be active.
func handle_type(selectedIndex:int):
	var properIndex = selectedIndex - 1
	
	if properIndex > -1:
		comment_panel.toggle_name(true)
	else:
		comment_panel.toggle_name(false)
	
	match properIndex:
		-1:#- Comment
			toggle_visibility(false)
		2,8:#- (2)Item, (8)DeathItem
			toggle_visibility(true, true, true, true, true, true, false, true)
		5:#- Package
			toggle_visibility(true, true, true, true, true, false, true, true)
		0,1,3,4,6,7,9,10,11:#- Everything else
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

#--- Parses the edit data for the name & comment.
func generate_comment_panel(edit):
	comment_panel.setup(edit.misc.comment, edit.misc.newlines, edit.type > -1, edit.misc.name)
	pass

#--- Parses the edit data for id and source.
func generate_source_panel(edit):
	source_panel.put(edit.objectId)
	pass

#--- Parses the edit data for string filters.
func generate_string_panel(edit):
	string_filters_panel.put(edit.stringFilters)
	pass

#--- Parses the edit data for form filters.
func generate_form_panel(edit):
	form_filters_panel.put(edit.formFilters)
	pass

#--- Parses the edit data for level filters.
func generate_level_panel(edit):
	_on_ActorLevelCheckBox_toggled(false)
	_on_ActorRangeButton_pressed()
	
	if edit.levelFilters == "NONE":
		return
	
	for filter in edit.levelFilters.split(","):
		if "(" in filter:#- Skill Level
			var node = load(skill_filter_prefab).instance()
			skill_filter_container.add_child(node)
			node.add_existing(filter)
		else:#- Actor Level
			actor_level_check_box.pressed = true
			if "/" in filter:
				var vals = filter.split("/", false)
				actor_range_button.pressed = true
				_on_ActorRangeButton_pressed()
				min_actor_spin_box.value = int(vals[0])
				max_actor_spin_box.value = int(vals[1])
			else:
				min_actor_spin_box.value = int(filter)
	pass

#--- Parses the edit data for trait filters.
func generate_trait_panel(edit):
	for t in edit.traitFilters.split('/'):
		match t.to_lower():
			"m","-m":#- Male filter.
				if "-"in t:
					f_check_box.pressed = true
				else:
					m_check_box.pressed = true
			"f","-f":#- Female filter.
				if "-"in t:
					m_check_box.pressed = true
				else:
					f_check_box.pressed = true
			"u","-u":#- Unique filter.
				if "-"in t:
					u_exclude_check_box.pressed = true
				u_check_box.pressed = true
			"s","-s":#- Unique filter.
				if "-"in t:
					s_exclude_check_box.pressed = true
				s_check_box.pressed = true
			"c","-c":#- Child filter.
				if "-"in t:
					c_exclude_check_box.pressed = true
				c_check_box.pressed = true
			"l","-l":#- Child filter.
				if "-"in t:
					l_exclude_check_box.pressed = true
				l_check_box.pressed = true
			"t","-t":#- Child filter.
				if "-"in t:
					t_exclude_check_box.pressed = true
				t_check_box.pressed = true
	
	_on_UCheckBox_pressed()
	_on_SCheckBox_pressed()
	_on_CCheckBox_pressed()
	_on_LCheckBox_pressed()
	_on_TCheckBox_pressed()
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

func _on_LCheckBox_pressed():
	if l_check_box.pressed:
		l_exclude_check_box.disabled = false
	else:
		l_exclude_check_box.pressed = false
		l_exclude_check_box.disabled = true
	pass

func _on_TCheckBox_pressed():
	if t_check_box.pressed:
		t_exclude_check_box.disabled = false
	else:
		t_exclude_check_box.pressed = false
		t_exclude_check_box.disabled = true
	pass

func _on_FormAddButton_pressed():
	var filter = load(form_filter_prefab).instance()
	form_filter_container.add_child(filter)
	filter.add_node()
	pass

func _on_ActorRangeButton_pressed():
	if actor_range_button.pressed:
		actor_range_button.icon = unlocked_range
		max_actor_spin_box.editable = true
	else:
		actor_range_button.icon = locked_range
		max_actor_spin_box.editable = false
	max_actor_spin_box.value = min_actor_spin_box.value
	pass

func _on_ActorLevelCheckBox_toggled(button_pressed):
	actor_level_filter.visible = button_pressed
	pass

func _on_SkillAddButton_pressed():
	var filter = load(skill_filter_prefab).instance()
	skill_filter_container.add_child(filter)
	pass
