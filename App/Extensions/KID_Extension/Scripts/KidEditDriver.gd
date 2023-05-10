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
	
	
	#- Assign data to edit
	source_panel.assign_data(edit)
	
	if not isNew:
		var ogEdit = interp.edits[workingIndex]
		var linesToAdd = 0
		
		if (edit.name != "" || edit.comments.size() > 0) && (ogEdit.name == "" && ogEdit.comments.size() == 0):
			linesToAdd += 1
		elif (edit.name == "" && edit.comments.size() == 0) && (ogEdit.name != "" || ogEdit.comments.size() > 0):
			linesToAdd -= 1
		
		if edit.comments.size() > ogEdit.comments.size() && edit.comments.size() > 1:
			linesToAdd += (edit.comments.size() - ogEdit.comments.size()) - 1
		elif edit.comments.size() < ogEdit.comments.size() && ogEdit.comments.size() > 1:
			linesToAdd -= (ogEdit.comments.size() - edit.comments.size()) + 1
		
		edit.lineNumber = ogEdit.lineNumber + linesToAdd
		interp.edits[workingIndex] = edit
		Globals.get_manager("console").post("Modified (" + interpreter.get_edit_name(interp, workingIndex) + ")")
	else:
		var lNum = 1
		if interp.edits.size() > 0:
			var prevEdit = interp.edits[interp.edits.size()-1] 
			lNum = prevEdit.lineNumber + prevEdit.newlines + prevEdit.comments.size()
		edit.lineNumber = lNum
		interp.edits.append(edit)
		Globals.get_manager("console").post("Created (" + interpreter.get_edit_name(interp, interp.edits.size()-1) + ")")
	pass

#--- CUSTOM: Called by the apply edit button.
func _on_ApplyButton_pressed():
	notify_system()
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
		6,7,10,14,15,17,18: #- GENERICS: Scroll, Location, Misc Item, Key, Activator, Flora, Race, Talking Activator
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
