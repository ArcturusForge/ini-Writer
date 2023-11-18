extends Node

#--- Determines if ini file matches extension use-case.
func data_matched(_raw:String, fileName:String):
	if "_DISTR" in fileName:
		return true
	else:
		return false

const my_id = "SPID"
var pop_manager
var console_manager
#--- Called by system when the extension is enabled.
func enable():
	Globals.Version_Check("2.0.0")
	pop_manager = Globals.get_manager("popup")
	console_manager = Globals.get_manager("console")
	
	var viewPop = pop_manager.get_popup_data("view")
	viewPop.register_entity(my_id, self, "handle_view")
	viewPop.add_option(my_id, spidOption)
	pass

const spidOption = "SPID Mod Page"
func handle_view(selected):
	match selected:
		spidOption:
			Functions.open_link("https://www.nexusmods.com/skyrimspecialedition/mods/36869")
			console_manager.generate("Opening link to SPID's mod page...", Globals.green)
	pass

#--- Called by system when the extension is disabled.
func disable():
	var viewPop = pop_manager.get_popup_data("view")
	viewPop.unregister_entity(my_id)
	console_manager.post("Unloaded SPID Writer")
	pass

func create_new_edit()->Dictionary:
	var edit = {
		"type":-1,
		"misc":{
			"name":"",
			"comment":"",
			"newlines":1,
			"lineStart":-1,
			"lineEnd":-1
		},
		"objectId":"",
		"stringFilters":"NONE",
		"formFilters":"NONE",
		"levelFilters":"NONE",
		"traitFilters":"NONE",
		"countOrIndex":1,
		"chance":100
	}
	return edit

#--- Called by system to structure interp data to be compatible with extension.
func init_interp():
	var interp = {
		"edits":[]
	}
	return interp

#--- Interpretes the raw string data to data structures used in editor.
func raw_to_interp(raw:String):
	var symbols = [
		Parser.create_symbol(-2, ";[", "", ["]"]),
		Parser.create_symbol(-1, ";[", "", [], ["]"]),
		Parser.create_symbol(-1, ";", "", [], [";["]),
		Parser.create_symbol(0, "Spell ="),
		Parser.create_symbol(1, "Perk ="),
		Parser.create_symbol(2, "Item ="),
		Parser.create_symbol(3, "Shout ="),
		Parser.create_symbol(4, "LevSpell ="),
		Parser.create_symbol(5, "Package ="),
		Parser.create_symbol(6, "Outfit ="),
		Parser.create_symbol(7, "Keyword ="),
		Parser.create_symbol(8, "DeathItem ="),
		Parser.create_symbol(9, "Faction ="),
		Parser.create_symbol(10, "SleepOutfit ="),
		Parser.create_symbol(11, "Skin ="),
	]
	
	var lines := Parser.parse_lines(raw, symbols)
	var interp = {
		"edits":[]
	}
	
	var headerLine:Dictionary
	for curLine in lines:
		var edit = create_new_edit()
		edit.type = curLine.type
		
		if curLine.type >= -1:
			edit.misc.lineEnd = curLine.lineNumber
		
		if curLine.type >= 0 && !headerLine.empty():
			edit.misc.name = headerLine.name
			edit.misc.comment = headerLine.comment
			edit.misc.lineStart = headerLine.lineStart
			headerLine.clear()
		
		match curLine.type:
			-8: #- Empty Line
				if interp.edits.size() > 0:
					interp.edits[interp.edits.size()-1].misc.newlines += 1
			-2: #- Edit Header
				var t:String = curLine.line
				t.erase(0,2)
				var vars = t.split("]")
				headerLine = {
					"name":vars[0],
					"comment":vars[1],
					"lineStart":curLine.lineNumber
				}
			-1: #- Comment
				var t:String = curLine.line
				t.erase(0,1)
				edit.misc.comment = t
			0: #- Spell = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				curLine.line = curLine.line.replace("Spell = ", "")
			1: #- Perk = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				curLine.line = curLine.line.replace("Perk = ", "")
			2: #- Item = RecordID|StringFilters|FormFilters|LevelFilters|Traits|ItemCount|Chance
				curLine.line = curLine.line.replace("Item = ", "")
			3: #- Shout = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				curLine.line = curLine.line.replace("Shout = ", "")
			4: #- LevSpell = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				curLine.line = curLine.line.replace("LevSpell = ", "")
			5: #- Package = RecordID|StringFilters|FormFilters|LevelFilters|Traits|PackageIdx|Chance
				curLine.line = curLine.line.replace("Package = ", "")
			6: #- Outfit = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				curLine.line = curLine.line.replace("Outfit = ", "")
			7: #- Keyword = RecordID or CustomString|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				curLine.line = curLine.line.replace("Keyword = ", "")
			8: #- DeathItem = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				curLine.line = curLine.line.replace("DeathItem = ", "")
			9: #- Faction = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				curLine.line = curLine.line.replace("Faction = ", "")
			10: #- SleepOutfit = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				curLine.line = curLine.line.replace("SleepOutfit = ", "")
			11: #- Skin = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				curLine.line = curLine.line.replace("Skin = ", "")
		
		if curLine.type == 2:
			write_to_edit(curLine.line, edit, 1)
		elif curLine.type == 5:
			write_to_edit(curLine.line, edit, 0)
		elif curLine.type >= 0:
			write_to_edit(curLine.line, edit)
		elif curLine.type < -1:
			continue
		
		interp.edits.append(edit)
	return interp
	

func write_to_edit(line:String, edit:Dictionary, countOrIndexDefault:=-1)->void: #- No return because it uses the same reference.
	var vals :PoolStringArray = line.split("|")
	edit.objectId = vals[0]
	edit.stringFilters = vals[1] if vals.size() >= 2 else "NONE"
	edit.formFilters = vals[2] if vals.size() >= 3 else "NONE"
	edit.levelFilters = vals[3] if vals.size() >= 4 else "NONE"
	edit.traitFilters = vals[4] if vals.size() >= 5 else "NONE"
	edit.chance = int(vals[6]) if vals.size() >= 7 else 100
	if countOrIndexDefault > -1:
		edit.countOrIndex = int(vals[5]) if vals.size() >= 6 else countOrIndexDefault
	else:
		edit.countOrIndex = 1
	

#--- Compiles the interp data into raw string format for ini-extension syntax.
func interp_to_raw(interp): # interp = {}
	var raw = ""
	for i in range(interp.edits.size()):
		var edit = interp.edits[i]
		var line:String
		
		if edit.misc.comment != "" && edit.type >= 0:
			line += ";[" + edit.misc.name + "]" + edit.misc.comment + "\n"
		
		match edit.type:
			-1: #- Comment
				line += ";" + edit.misc.comment
			0: #- Spell = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				line += "Spell = "
			1: #- Perk = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				line += "Perk = "
			2: #- Item = RecordID|StringFilters|FormFilters|LevelFilters|Traits|ItemCount|Chance
				line += "Item = "
			3: #- Shout = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				line += "Shout = "
			4: #- LevSpell = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				line += "LevSpell = "
			5: #- Package = RecordID|StringFilters|FormFilters|LevelFilters|Traits|PackageIdx|Chance
				line += "Package = "
			6: #- Outfit = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				line += "Outfit = "
			7: #- Keyword = RecordID or CustomString|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				line += "Keyword = "
			8: #- DeathItem = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				line += "DeathItem = "
			9: #- Faction = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				line += "Faction = "
			10: #- SleepOutfit = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				line += "SleepOutfit = "
			11: #- Skin = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
				line += "Skin = "
		
		var amountOrIndex:=""
		if edit.type == 2 || edit.type == 5:
			amountOrIndex = str(edit.countOrIndex)
		elif edit.type >= 0:
			amountOrIndex = "NONE"
		
		if edit.type >= 0:
			line += edit.objectId + "|" + edit.stringFilters + "|" + edit.formFilters + "|" + edit.levelFilters + "|" + edit.traitFilters + "|" + amountOrIndex + "|" + str(edit.chance)
			line = line.replace("|NONE|NONE|NONE|NONE|NONE|100", "")
			line = line.replace("|NONE|NONE|NONE|NONE|1|100", "")
			line = line.replace("|NONE|NONE|NONE|NONE|0|100", "")
			line = line.replace("|NONE|NONE|NONE|NONE|100", "")
			line = line.replace("|NONE|NONE|NONE|1|100", "")
			line = line.replace("|NONE|NONE|NONE|0|100", "")
			line = line.replace("|NONE|NONE|NONE|100", "")
			line = line.replace("|NONE|NONE|1|100", "")
			line = line.replace("|NONE|NONE|0|100", "")
			line = line.replace("|NONE|NONE|100", "")
			line = line.replace("|NONE|1|100", "")
			line = line.replace("|NONE|0|100", "")
			line = line.replace("|NONE|100", "")
			line = line.replace("|1|100", "")
			line = line.replace("|0|100", "")
			line = line.replace("|100", "")
		
		raw += line
		var newlineAdditons = edit.misc.newlines if i < interp.edits.size() - 1 else edit.misc.newlines - 1
		for _i in range(newlineAdditons):
			raw += "\n"
	return raw

#--- Intercepts the filesave process to alter the file name before it is saved.
func alter_save_name(originalName:String):
	if not "_DISTR" in originalName:
		originalName += "_DISTR"
	return originalName

#--- Moves an edit from the origIndex to the targetIndex.
func move_index_to(interp, origIndex, targetIndex):
	var data = interp.edits[origIndex]
	interp.edits.remove(origIndex)
	interp.edits.insert(targetIndex, data)
	pass

#--- Returns the total amount of edits in the interp data.
func get_edit_count(interp):
	return interp.edits.size()

#--- Returns the name of an edit inside the interp data.
func get_edit_name(interp, index, withLineNumber=true):
	var edit = interp.edits[index]
	var eName:String
	if withLineNumber:
		if edit.type >= 0 && edit.misc.lineStart > -1:
			eName += str(edit.misc.lineStart) + "~" + str(edit.misc.lineEnd) + " "
		else:
			eName += str(edit.misc.lineEnd) + " "
	
	match edit.type:
		-1: #- (-1)Comment
			eName += "Comment: " + edit.misc.comment
			return eName
		0: #- (0)Spell
			eName += "Spell: "
		1: #- (1)Perk
			eName += "Perk: "
		2: #- (2)Item
			eName += "Item: "
		3: #- (3)Shout
			eName += "Shout: "
		4: #- (4)LevSpell
			eName += "LevSpell: "
		5: #- (5)Package
			eName += "Package: "
		6: #- (6)Outfit
			eName += "Outfit: "
		7: #- (7)Keyword
			eName += "Keyword: "
		8: #- (8)DeathItem
			eName += "DeathItem: "
		9: #- (9)Faction
			eName += "Faction: "
		10: #- (10)SleepOutfit
			eName += "SleepOutfit: "
		11: #- (11)Skin
			eName += "Skin: "
	if edit.misc.name == "":
		eName += edit.objectId
	else:
		eName += edit.misc.name
	return eName

#--- Called by the system to remove an edit from circulation.
func delete_edit(index, interp):
	interp.edits.remove(index)
	pass
