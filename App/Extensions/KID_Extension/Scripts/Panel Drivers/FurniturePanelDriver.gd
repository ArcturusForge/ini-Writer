extends PanelContainer

#-- Scene Refs
onready var furniture_type_select = $VBoxContainer/FurnitureTypeSelect
onready var bench_type_select = $VBoxContainer/BenchTypeSelect
onready var usage_skill_select = $VBoxContainer/UsageSkillSelect

#--- SYSTEM: Reset ui to init user state.
func init():
	pass

#--- Used to init the ui.
func set_data(edit):
	for trait in edit.traitFilters:
		var lt = trait.to_lower()
		if "bt(" in lt:
			bench_type_select.selected = int(lt.replace("bt(", "").replace(")", ""))
		elif "t(" in lt:
			furniture_type_select.selected = int(lt.replace("t(", "").replace(")", "")) + 1
		elif "us(" in lt:
			match int(lt.replace("us(", "").replace(")", "")):
				6: #- OneHanded 
					usage_skill_select.selected = 1
				7:#- TwoHanded 
					usage_skill_select.selected = 2
				8: #- Marksman 
					usage_skill_select.selected = 3
				9: #- Block 
					usage_skill_select.selected = 4
				10: #- Smithing 
					usage_skill_select.selected = 5
				11: #- HeavyArmor 
					usage_skill_select.selected = 6
				12: #- LightArmor 
					usage_skill_select.selected = 7
				13: #- Pickpocket 
					usage_skill_select.selected = 8
				14: #- Lockpicking 
					usage_skill_select.selected = 9
				15: #- Sneak 
					usage_skill_select.selected = 10
				16: #- Alchemy 
					usage_skill_select.selected = 11
				17: #- Speechcraft 
					usage_skill_select.selected = 12
				18: #- Alteration 
					usage_skill_select.selected = 13
				19: #- Conjuration 
					usage_skill_select.selected = 14
				20: #- Destruction 
					usage_skill_select.selected = 15
				21: #- Illusion 
					usage_skill_select.selected = 16
				22: #- Restoration 
					usage_skill_select.selected = 17
				23: #- Enchanting 
					usage_skill_select.selected = 18
	init()
	pass

#--- Used to compile the data into an edit.
#--- [edit] is an instance reference so changes will apply for all ref holders.
func apply_data(edit):
	if furniture_type_select.selected > 0:
		edit.traitFilters.append("T(" + str(furniture_type_select.selected - 1) + ")")
	
	if bench_type_select.selected > 0: #- Note there is no -1 because bench types start at 1.
		edit.traitFilters.append("BT(" + str(bench_type_select.selected) + ")")
	
	if usage_skill_select.selected > 0:
		match usage_skill_select.selected:
			1: #- OneHanded 
				edit.traitFilters.append("US(6)")
			2:#- TwoHanded 
				edit.traitFilters.append("US(7)")
			3: #- Marksman 
				edit.traitFilters.append("US(8)")
			4: #- Block 
				edit.traitFilters.append("US(9)")
			5: #- Smithing 
				edit.traitFilters.append("US(10)")
			6: #- HeavyArmor 
				edit.traitFilters.append("US(11)")
			7: #- LightArmor 
				edit.traitFilters.append("US(12)")
			8: #- Pickpocket 
				edit.traitFilters.append("US(13)")
			9: #- Lockpicking 
				edit.traitFilters.append("US(14)")
			10: #- Sneak 
				edit.traitFilters.append("US(15)")
			11: #- Alchemy 
				edit.traitFilters.append("US(16)")
			12: #- Speechcraft 
				edit.traitFilters.append("US(17)")
			13: #- Alteration 
				edit.traitFilters.append("US(18)")
			14: #- Conjuration 
				edit.traitFilters.append("US(19)")
			15: #- Destruction 
				edit.traitFilters.append("US(20)")
			16: #- Illusion 
				edit.traitFilters.append("US(21)")
			17: #- Restoration 
				edit.traitFilters.append("US(22)")
			18: #- Enchanting 
				edit.traitFilters.append("US(23)")
	pass
