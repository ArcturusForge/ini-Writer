extends Node

#--- Determines wether ini file matches extension use-case.
func data_matched(raw:String, fileName:String):
	if "_DISTR" in fileName:
		return true
	else:
		return false

func create_new_edit():
	var edit = {
		"newlines":1, #- For how many empty lines after the edit.
		"type":-1,
		"name":"",
		"comment":"",
		"objectId":{
			"type":0, #- Types: (0)editorID, (1)esp/esm[6digits], (2)esl[3digits]
			"value":"", #- Erase leading 0's if there are any. -> {00}65AFD
			"source":""
		},
		"stringFilters":[],
		"formFilters":[],
		"levelFilters":[],
		"traitFilters":[],
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
	raw.replace("\r", "\n")
	var lines = raw.split("\n")
	var interp = {
		"edits":[]
	}
	
	var prevLine = ""
	for i in range(lines.size()):
		var edit = create_new_edit()
		var line:String = lines[i]
		var t = line.replace(" ", "")
		if line == "":
			#- Line is empty
			if interp.edits.size() > 0:
				var lastEdit = interp.edits[interp.edits.size() - 1]
				lastEdit.newlines += 1
		elif t[0] == ";":
			#- Line is comment.
			if "]" in line:
				#- line is part of the next line: Next should be a SPID edit line.
				prevLine = line
			else:
				#- Line is just a user comment.
				edit.comment = line.replace(";", "")
				interp.edits.append(edit)
		else:
			#- Line is a SPID edit.
			if not " = " in line:
				continue #- Somethings wrong here.
			
			var data = t.split("=")
			var type:String = data[0].to_lower()
			match type:
				"spell":
					# Spell = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
					edit.type = 0
					write_to_edit(edit, data, line)
				"perk":
					# Perk = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
					edit.type = 1
					write_to_edit(edit, data, line)
				"item":
					# Item = RecordID|StringFilters|FormFilters|LevelFilters|Traits|ItemCount|Chance
					edit.type = 2
					write_to_edit(edit, data, line)
				"shout":
					# Shout = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
					edit.type = 3
					write_to_edit(edit, data, line)
				"levspell":
					# LevSpell = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
					edit.type = 4
					write_to_edit(edit, data, line)
				"package":
					# Package = RecordID|StringFilters|FormFilters|LevelFilters|Traits|PackageIdx|Chance
					edit.type = 5
					write_to_edit(edit, data, line)
				"outfit":
					# Outfit = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
					edit.type = 6
					write_to_edit(edit, data, line)
				"keyword":
					# Keyword = RecordID or CustomString|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
					edit.type = 7
					write_to_edit(edit, data, line)
				"deathitem":
					# DeathItem = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
					edit.type = 8
					write_to_edit(edit, data, line)
				"faction":
					# Faction = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
					edit.type = 9
					write_to_edit(edit, data, line)
				"sleepoutfit":
					# SleepOutfit = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
					edit.type = 10
					write_to_edit(edit, data, line)
				"skin":
					# Skin = RecordID|StringFilters|FormFilters|LevelFilters|Traits|NONE|Chance
					edit.type = 11
					write_to_edit(edit, data, line)
				#"":
			
			#- Read through the previous line to parse the comment info.
			#_TODO: Support multi-line comments.
			if not prevLine == "":
				var ldata = prevLine.split("]")
				edit.name = ldata[0].replace(";[", "")
				edit.comment = ldata[1]
				prevLine = ""
			interp.edits.append(edit)
	return interp

func write_to_edit(edit, data, origLine):
	#- edit is a reference-typed data structure and therefore all changes
	#- are made to the same instance.
	var commands = data[1].split("|")
	#- Parse the commands from the edit.
	for x in range(commands.size()):
		var command:String = commands[x]
		match x:
			0: #- RecordID
				if "~" in command || "0x" in command:
					#- Was formID.
					var formAndSource = command.split("x")[1] if "0x" in command else command
					var id:String = formAndSource.split("~")[0] if "~" in formAndSource else formAndSource
					if (id.length() > 3 || "esp" in command || "esm" in command) && not "esl" in command: #- esp or esm.
						edit.objectId.type = 1
					else: #- esl.
						edit.objectId.type = 2
				else:
					#- Was editorID.
					edit.objectId.type = 0
				match edit.objectId.type:
					0:#- EditorID
						edit.objectId.value = origLine.split(" = ")[1].split("|")[0]
						edit.objectId.source = "AUTO"
					1, 2:#- Esp/Esm/Esl
						var formAndSource = command.split("x")[1]
						var id:String = formAndSource.split("~")[0] if "~" in formAndSource else formAndSource
						edit.objectId.value = id
						edit.objectId.source = formAndSource.split("~")[1] if "~" in formAndSource else "Skyrim and DLC"
			1: #- StringFilters
				parse_comma_segment("stringFilters", command, edit)
			2: #- FormFilters
				parse_comma_segment("formFilters", command, edit)
			3: #- LevelFilters
				parse_comma_segment("levelFilters", command, edit)
			4: #- TraitFilters
				parse_comma_segment("traitFilters", command, edit, "/")
			5: #- Count Or Index
				edit.countOrIndex = int(command)
			6: #- Chance
				edit.chance = int(command)

#--- Parses segments that are seperated by commas.
func parse_comma_segment(segment, command, edit, splitSymbol=","):
	var filters = []
	if not command == "NONE":
		#- Split by ',' and store array.
		var args = command.split(splitSymbol, false)
		for arg in args:
			if "+" in arg:
				var filter = []
				var adds = arg.split("+")
				for add in adds:
					filter.append(add)
				filters.append(filter)
			else:
				filters.append([arg])
	edit[segment] = filters
	pass

#--- Compiles the interp data into raw string format for ini-extension syntax.
func interp_to_raw(interp): # interp = {}
	var raw = ""
	for edit in interp.edits:
		#- SPID edit type: 
		if edit.type == -1: #- (-1)Comment
			raw += ";" + edit.comment
			for i in range(edit.newlines):
				raw += "\n"
			continue
		
		if not edit.type == -1 && not edit.comment == "":
			raw += ";" + "[" + edit.name + "]" + edit.comment + "\n"
		
		var formID = ""
		match edit.objectId.type:
			0: #- EditorID
				formID = edit.objectId.value
			1: #- Esp/esm
				var t:String = edit.objectId.value
				if "0x" in t:
					t = t.replace("0x", "")
				while t.length() > 5:
					t.erase(0, 1)
				while t[0] == "0":
					t.erase(0, 1)
				formID = "0x" + t + "~" + edit.objectId.source
			2: #- Esl
				var t:String = edit.objectId.value
				if "0x" in t:
					t = t.replace("0x", "")
				while t.length() > 3:
					t.erase(0, 1)
				while t[0] == "0":
					t.erase(0, 1)
				formID = "0x" + t + "~" + edit.objectId.source
		
		var line
		match edit.type:
			0: #- (0)Spell
				line = "Spell = "
			1: #- (1)Perk
				line = "Perk = "
			2: #- (2)Item
				line = "Item = "
			3: #- (3)Shout
				line = "Shout = "
			4: #- (4)LevSpell
				line = "LevSpell = "
			5: #- (5)Package
				line = "Package = "
			6: #- (6)Outfit
				line = "Outfit = "
			7: #- (7)Keyword
				line = "Keyword = "
			8: #- (8)DeathItem
				line = "DeathItem = "
			9: #- (9)Faction
				line = "Faction = "
			10: #- (10)SleepOutfit
				line = "SleepOutfit = "
			11: #- (11)Skin
				line = "Skin = "
		line += formID + "|"
		
		#- StringFilters
		if edit.stringFilters.size() > 0:
			for i in range(edit.stringFilters.size()):
				var filters = edit.stringFilters[i]
				for x in range(filters.size()):
					var arg = filters[x]
					line += arg
					if x < filters.size() - 1:
						line += "+"
				if i < edit.stringFilters.size() - 1:
					line += ","
		else:
			line += "NONE"
		line += "|"
		
		#- FormFilters
		if edit.formFilters.size() > 0:
			for i in range(edit.formFilters.size()):
				var filters = edit.formFilters[i]
				for x in range(filters.size()):
					var arg = filters[x]
					line += arg
					if x < filters.size() - 1:
						line += "+"
				if i < edit.formFilters.size() - 1:
					line += ","
		else:
			line += "NONE"
		line += "|"
		
		#- LevelFilters
		if edit.levelFilters.size() > 0:
			for i in range(edit.levelFilters.size()):
				var filters = edit.levelFilters[i]
				for x in range(filters.size()):
					var arg = filters[x]
					line += arg
					if x < filters.size() - 1:
						line += "+"
				if i < edit.levelFilters.size() - 1:
					line += ","
		else:
			line += "NONE"
		line += "|"
		
		#- TraitFilters
		if edit.traitFilters.size() > 0:
			for i in range(edit.traitFilters.size()):
				var filter = edit.traitFilters[i]
				line += filter[0]
				if i < edit.traitFilters.size() - 1:
					line += "/"
		else:
			line += "NONE"
		line += "|"
		
		#- Count Or Index
		if edit.type == 2 || edit.type == 5: #- Item or Package
			line += str(edit.countOrIndex)
		else:
			line += "NONE"
		line += "|"
		
		#- Chance
		line += str(edit.chance)
		
		raw += line
		for i in range(edit.newlines):
			raw += "\n"
	return raw

#--- Intercepts the filesave process to alter the file name before it is saved.
func alter_save_name(originalName:String):
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
func get_edit_name(interp, index):
	var eName = ""
	var edit = interp.edits[index]
	match edit.type:
		-1: #- (-1)Comment
			eName = "Comment: " + edit.comment
			return eName
		0: #- (0)Spell
			eName = "Spell: "
		1: #- (1)Perk
			eName = "Perk: "
		2: #- (2)Item
			eName = "Item: "
		3: #- (3)Shout
			eName = "Shout: "
		4: #- (4)LevSpell
			eName = "LevSpell: "
		5: #- (5)Package
			eName = "Package: "
		6: #- (6)Outfit
			eName = "Outfit: "
		7: #- (7)Keyword
			eName = "Keyword: "
		8: #- (8)DeathItem
			eName = "DeathItem: "
		9: #- (9)Faction
			eName = "Faction: "
		10: #- (10)SleepOutfit
			eName = "SleepOutfit: "
		11: #- (11)Skin
			eName = "Skin: "
	if edit.name == "":
		eName += edit.objectId.value
	else:
		eName += edit.name
	return eName

#--- Called by the system to remove an edit from circulation.
func delete_edit(index, interp):
	interp.edits.remove(index)
	pass
