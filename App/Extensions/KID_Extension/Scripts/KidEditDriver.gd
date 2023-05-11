extends VBoxContainer

#-- Dynamic Vars
var workingIndex:int = -1 #- Points towards the index for this ini edit.
var system #- Points towards the editor window manager.
var interpreter #- The interpreter script from this particular extension.
var isNew:bool

#-- Scene Refs
onready var type_select:OptionButton = $TypePanel/VBoxContainer/TypeSelect
onready var name_label = $NamePanel/VBoxContainer/Label
onready var name_edit:LineEdit = $NamePanel/VBoxContainer/LineEdit
onready var comment_edit:TextEdit = $NamePanel/VBoxContainer/TextEdit

#-- Panels
onready var source_panel = $SourcePanel
onready var filters_panel = $FiltersPanel
onready var weapon_traits_panel = $WeaponTraitsPanel
onready var armor_traits_panel = $ArmorTraitsPanel
onready var ammo_traits_panel = $AmmoTraitsPanel
onready var magic_effect_traits_panel = $MagicEffectTraitsPanel
onready var potion_traits_panel = $PotionTraitsPanel
onready var ingredient_traits_panel = $IngredientTraitsPanel
onready var book_traits_panel = $BookTraitsPanel
onready var soul_gem_traits_panel = $SoulGemTraitsPanel
onready var spell_traits_panel = $SpellTraitsPanel
onready var furniture_traits_panel = $FurnitureTraitsPanel
onready var chance_panel = $ChancePanel

#--- Called by system to initialize the driver.
func init_driver(workingIndex, system, interpreter):
	self.workingIndex = workingIndex
	self.system = system
	self.interpreter = interpreter

	type_select.connect("item_selected", self, "handle_type_select")
	pass

#--- Called by system to modify an existing ini edit.
func modify_existing(interp):
	var edit = interp.edits[workingIndex]
	isNew = false
	draw_ui(edit)
	pass

#--- Called by system to write a new ini edit.
func create_new():
	var edit = interpreter.create_new_edit()
	isNew = true
	draw_ui(edit)
	pass

#--- Call this to notify the system of changes made.
func notify_system():
	system.alert_to_edits()
	pass

#--- Called by system to apply changes to the ini edit.
func apply_edit(interp):
	var edit = interpreter.create_new_edit()
	edit.name = name_edit.text
	edit.comments = comment_edit.text.split("\n", false)
	
	if type_select.selected == 0:
		edit.type = -1
	else:
		edit.type = 0
		edit.itemType = type_select.selected - 1
		apply_trait_data(edit)
	
	
	#- Assign data to edit
	source_panel.apply_data(edit)
	
	#- Generate line number and assign to interp database.
	if not isNew:
		var ogEdit = interp.edits[workingIndex]
		var ogLines = 0
		if ogEdit.comments.size() > 0:
			ogLines += ogEdit.comments.size()
		elif ogEdit.name != "":
			ogLines += 1
			
		var lNum = 1 if edit.type != -1 else 0
		if edit.comments.size() < ogEdit.comments.size():
			var dif = abs(edit.comments.size() - ogEdit.comments.size())
			lNum += ogLines - dif
			#- Propagate the difference in line number to proceeding edits.
			for i in range(workingIndex + 1, interp.edits.size()):
				var procEdit = interp.edits[i]
				procEdit.lineNumber -= dif
		elif edit.comments.size() > ogEdit.comments.size():
			var dif = abs(edit.comments.size() - ogEdit.comments.size())
			lNum += ogLines + dif
			#- Propagate the difference in line number to proceeding edits.
			for i in range(workingIndex + 1, interp.edits.size()):
				var procEdit = interp.edits[i]
				procEdit.lineNumber += dif
		else:
			lNum = ogEdit.lineNumber

		edit.lineNumber = lNum
		interp.edits[workingIndex] = edit
		Globals.get_manager("console").post("Modified (" + interpreter.get_edit_name(interp, workingIndex) + ")")
	else:
		var lNum = 1 if edit.type != -1 else 0
		if interp.edits.size() > 0:
			var prevEdit = interp.edits[interp.edits.size()-1] 
			lNum += prevEdit.lineNumber + prevEdit.newlines - 1
		
		if edit.comments.size() > 0:
			lNum += edit.comments.size()
		elif edit.name != "":
			lNum += 1
		
		edit.lineNumber = lNum
		interp.edits.append(edit)
		Globals.get_manager("console").post("Created (" + interpreter.get_edit_name(interp, interp.edits.size()-1) + ")")
	pass

#--- CUSTOM: Called by the apply edit button.
func _on_ApplyButton_pressed():
	notify_system()
	pass

#--- CUSTOM: Called by the cancel edit button.
func _on_CancelButton_pressed():
	system.cancel_create()
	pass

#--- CUSTOM: Generate the UI for a particular edit.
func draw_ui(edit):
	if edit.type == -1:
		type_select.selected = 0
	else:
		type_select.selected = edit.itemType + 1
	handle_type_select(type_select.selected)
	
	name_edit.text = edit.name
	for comment in edit.comments:
		if comment == "":
			continue
		comment_edit.text += comment + "\n"

	source_panel.set_data(edit)
	init_panels()
	set_trait_data(edit)
	pass

#--- CUSTOM: Handle which panels are active for the current edit type.
func handle_type_select(selected):
	match selected:
		0: #- Comment
			toggle_visiblity(false, false, false, false, false, false, false, false, false, false, false, false, false, false)
		1: #- Weapon
			toggle_visiblity(true, true, true, true)
		2: #- Armor
			toggle_visiblity(true, true, true, false, true)
		3: #- Ammo
			toggle_visiblity(true, true, true, false, false, true)
		4: #- Magic effect
			toggle_visiblity(true, true, true, false, false, false, true)
		5: #- Potion
			toggle_visiblity(true, true, true, false, false, false, false, true)
		8: #- Ingredient
			toggle_visiblity(true, true, true, false, false, false, false, false, true)
		9: #- Book
			toggle_visiblity(true, true, true, false, false, false, false, false, false, true)
		12: #- Soulgem
			toggle_visiblity(true, true, true, false, false, false, false, false, false, false, true)
		13,19: #- Spell, Enchantment
			toggle_visiblity(true, true, true, false, false, false, false, false, false, false, false, true)
		16: #- Furniture
			toggle_visiblity(true, true, true, false, false, false, false, false, false, false, false, false, true)
		6,7,10,11,14,15,17,18: #- GENERICS: Scroll, Location, Misc Item, Key, Activator, Flora, Race, Talking Activator
			toggle_visiblity(true, true, true)
	pass

#--- CUSTOM: Utility for toggling visibility
func toggle_visiblity(name:bool, source:bool, filters:bool, weapon:bool = false, armor:bool = false, ammo:bool = false, magic:bool = false, potion:bool = false, ingredient:bool = false, book:bool = false, soulgem:bool = false, spell:bool = false, furniture:bool = false, chance:bool = true):
	name_label.visible = name
	name_edit.visible = name
	source_panel.visible = source
	filters_panel.visible = filters
	weapon_traits_panel.visible = weapon
	armor_traits_panel.visible = armor
	ammo_traits_panel.visible = ammo
	magic_effect_traits_panel.visible = magic
	potion_traits_panel.visible = potion
	ingredient_traits_panel.visible = ingredient
	book_traits_panel.visible = book
	soul_gem_traits_panel.visible = soulgem
	spell_traits_panel.visible = spell
	furniture_traits_panel.visible = furniture
	chance_panel.visible = chance
	pass

#--- CUSTOM: Utility for reseting panels to default state
func init_panels():
	weapon_traits_panel.init()
	armor_traits_panel.init()
	# ammo_traits_panel.init()
	# magic_effect_traits_panel.init()
	# potion_traits_panel.init()
	# ingredient_traits_panel.init()
	# book_traits_panel.init()
	# soul_gem_traits_panel.init()
	# spell_traits_panel.init()
	# furniture_traits_panel.init()
	pass

#--- CUSTOM: Utility for assigning trait data to the edit's type panel.
func set_trait_data(edit):
	match edit.itemType + 1:
		1: #- Weapon
			weapon_traits_panel.set_data(edit)
		2: #- Armor
			armor_traits_panel.set_data(edit)
		3: #- Ammo
			ammo_traits_panel.set_data(edit)
		4: #- Magic effect
			magic_effect_traits_panel.set_data(edit)
		5: #- Potion
			potion_traits_panel.set_data(edit)
		8: #- Ingredient
			ingredient_traits_panel.set_data(edit)
		9: #- Book
			book_traits_panel.set_data(edit)
		12: #- Soulgem
			soul_gem_traits_panel.set_data(edit)
		13,19: #- Spell, Enchantment
			spell_traits_panel.set_data(edit)
		16: #- Furniture
			furniture_traits_panel.set_data(edit)
	pass

#--- CUSTOM: Utility for applying user edits to the KID file.
func apply_trait_data(edit):
	match edit.itemType + 1:
		1: #- Weapon
			weapon_traits_panel.apply_data(edit)
		2: #- Armor
			armor_traits_panel.apply_data(edit)
		3: #- Ammo
			ammo_traits_panel.apply_data(edit)
		4: #- Magic effect
			magic_effect_traits_panel.apply_data(edit)
		5: #- Potion
			potion_traits_panel.apply_data(edit)
		8: #- Ingredient
			ingredient_traits_panel.apply_data(edit)
		9: #- Book
			book_traits_panel.apply_data(edit)
		12: #- Soulgem
			soul_gem_traits_panel.apply_data(edit)
		13,19: #- Spell, Enchantment
			spell_traits_panel.apply_data(edit)
		16: #- Furniture
			furniture_traits_panel.apply_data(edit)
	pass
