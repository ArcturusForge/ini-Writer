extends PanelContainer

#-- Scene Refs
onready var spell_type_select = $VBoxContainer/SpellTypeSelect
onready var delivery_type_select = $VBoxContainer/DeliveryTypeSelect
onready var casting_type_select = $VBoxContainer/CastingTypeSelect
onready var school_select = $VBoxContainer/SchoolSelect

#--- SYSTEM: Reset ui to init user state.
func init():
	pass

#--- Used to init the ui.
func set_data(edit):
	for trait in edit.traitFilters:
		var lt = trait.to_lower()
		if "st(" in lt:
			spell_type_select.selected = int(lt.replace("st(", "").replace(")", "")) + 1
		elif "d(" in lt:
			delivery_type_select.selected = int(lt.replace("d(", "").replace(")", "")) + 1
		elif "ct(" in lt:
			casting_type_select.selected = int(lt.replace("ct(", "").replace(")", "")) + 1
		else:
			match int(lt):
				18: #- Alteration 
					school_select.selected = 1
				19:#- Conjuration 
					school_select.selected = 2
				20: #- Destruction 
					school_select.selected = 3
				21: #- Illusion 
					school_select.selected = 4
				22: #- Restoration 
					school_select.selected = 5
	init()
	pass

#--- Used to compile the data into an edit.
#--- [edit] is an instance reference so changes will apply for all ref holders.
func apply_data(edit):
	if spell_type_select.selected > 0:
		edit.traitFilters.append("ST(" + str(spell_type_select.selected - 1) + ")")
	
	if delivery_type_select.selected > 0:
		edit.traitFilters.append("D(" + str(delivery_type_select.selected - 1) + ")")
	
	if casting_type_select.selected > 0:
		edit.traitFilters.append("CT(" + str(casting_type_select.selected - 1) + ")")
	
	match school_select.selected:
		1: #- Alteration 
			edit.traitFilters.append(str(18))
		2:#- Conjuration 
			edit.traitFilters.append(str(19))
		3: #- Destruction 
			edit.traitFilters.append(str(20))
		4: #- Illusion 
			edit.traitFilters.append(str(21))
		5: #- Restoration 
			edit.traitFilters.append(str(22))
	pass

