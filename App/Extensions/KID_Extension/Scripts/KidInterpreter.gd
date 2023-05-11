extends Node

const my_id = "KID"
const kidOption = "KID Mod Page"

var pop_manager
var console_manager

#--- Determines if ini file matches extension use-case.
func data_matched(_raw:String, fileName:String):
	if "_KID" in fileName:
		return true
	else:
		return false

#--- Called by system when the extension is enabled.
func enable():
	pop_manager = Globals.get_manager("popup")
	console_manager = Globals.get_manager("console")
	
	var viewPop = pop_manager.get_popup_data("view")
	viewPop.register_entity(my_id, self, "handle_view")
	viewPop.add_option(my_id, kidOption)
	pass

#--- Called by system when the extension is disabled.
func disable():
	var viewPop = pop_manager.get_popup_data("view")
	viewPop.unregister_entity(my_id)
	console_manager.post("Unloaded KID Writer")
	pass

#--- Called by system to structure interp data to be compatible with extension.
func init_interp():
	var interp = {
		"edits":[]
	}
	return interp

#--- Interpretes the raw string data to data structures used in editor.
func raw_to_interp(raw:String):
	var util = ResourceLoader.load("res://App/Extensions/KID_Extension/Scripts/Utils/Inline_Parser.gd").new()
	var symbols = {
		";":-1,
		"Keyword =":0
	}
	
	#- Split and type each line in raw.
	var parsed_lines = util.split_and_define_lines(raw, symbols)
	
	#- Create a fresh interp dataset.
	var interp = init_interp()

	#- Vars for the current edit.
	var editComment = null
	var previousEdit = null

	#- Loops through the parsed lines for converting into interp data.
	for parsed in parsed_lines:
		#- Assign type before handling it.
		var currentEdit = create_new_edit()
		currentEdit.type = parsed.type
		currentEdit.lineNumber = parsed.line_number
		var line = parsed.line
		var skipEdit = false

		match parsed.type:
			0:#- KID edit
				#- Add comment to KID edit.
				if not editComment == null:
					currentEdit.name = editComment.name
					currentEdit.comments = editComment.comments
					editComment = null
				
				#--- BEGIN: Parse the edit
				
				#- Normalize opening tag
				line = line.replace(" = ", "=")
				line = line.replace(" =", "=")
				line = line.replace("= ", "=")
				
				#- Split by opening tag
				var filters = line.get_slice("=", 1).split("|")
				#- Filters contains:
				# formID~esp(OR)keywordEditorID|type|strings,formIDs(OR)editorIDs|traits|chance
				for i in range(filters.size()):
					var currentFilter = filters[i]
					match i:
						0:#- Subject
							if "0x" in currentFilter || "0X" in currentFilter:
								#- Subject comes from FormID
								var id = currentFilter.get_slice("x", 1) if "0x" in currentFilter else currentFilter.get_slice("X", 1)
								if ".esm" in currentFilter || ".esp" in currentFilter:
									#- Comes from a different plugin than skyrim and the original dlc.
									currentEdit.objectId.type = 1
									currentEdit.objectId.value = id.get_slice("~", 0)
									currentEdit.objectId.source = id.get_slice("~", 1)
								elif ".esl" in currentFilter:
									#- Comes from a light plugin.
									currentEdit.objectId.type = 2
									currentEdit.objectId.value = id.get_slice("~", 0)
									currentEdit.objectId.source = id.get_slice("~", 1)
								else:
									#- Comes from skyrim or original dlc.
									currentEdit.objectId.type = 1
									currentEdit.objectId.value = id
							else:
								#- Subject comes from custom keyword.
								currentEdit.objectId.type = 0
								currentEdit.objectId.value = currentFilter
								pass
						1:#- Type
							match currentFilter.to_lower():
								"weapon":
									currentEdit.itemType = 0
								"armor":
									currentEdit.itemType = 1
								"ammo":
									currentEdit.itemType = 2
								"magic effect":
									currentEdit.itemType = 3
								"potion":
									currentEdit.itemType = 4
								"scroll":
									currentEdit.itemType = 5
								"location":
									currentEdit.itemType = 6
								"ingredient":
									currentEdit.itemType = 7
								"book":
									currentEdit.itemType = 8
								"misc item":
									currentEdit.itemType = 9
								"key":
									currentEdit.itemType = 10
								"soul gem":
									currentEdit.itemType = 11
								"spell":
									currentEdit.itemType = 12
								"activator":
									currentEdit.itemType = 13
								"flora":
									currentEdit.itemType = 14
								"furniture":
									currentEdit.itemType = 15
								"race":
									currentEdit.itemType = 16
								"talking activator":
									currentEdit.itemType = 17
								"enchantment":
									currentEdit.itemType = 18
						2:#- Strings, FormIDs, EditorIDs
							#- Bypass unused filter.
							if "NONE" in currentFilter:
								continue
							#- Split filters by common separator.
							currentEdit.stringAndFormFilters = currentFilter.split(",", false)
						3:#- Traits
							#- Bypass unused filter.
							if "NONE" in currentFilter:
								continue
							#- Split filters by common separator.
							currentEdit.traitFilters = currentFilter.split(",", false)
						4:#- Chance
							currentEdit.chance = int(currentFilter)
				pass
			-1:#- Comment
				if "[" in line && "]" in line:
					var commentSplit = line.split("]")
					var comName = commentSplit[0].split("[")[1]
					var comment = commentSplit[1]
					editComment = {
						"name":comName,
						"comments":[comment]
					}
					skipEdit = true
				elif not editComment == null: #- Line is a multi-line comment belonging to a KID edit.
					line.erase(0, 1)
					editComment.comments.append(line)
					skipEdit = true
				else: #- Line is a standalone comment.
					line.erase(0, 1)
					if not previousEdit == null && previousEdit.type == -1: #- Combines group comments into one comment edit.
						previousEdit.comments.append(line)
						previousEdit.lineNumber += 1
						skipEdit = true
					else:
						currentEdit.comments.append(line)
			-2:#- Empty line
				if previousEdit == null:
					skipEdit = true
					continue
				previousEdit.newlines += 1
				skipEdit = true
			-9:#- Untyped
				skipEdit = true
		
		#--- End: Parse the edit
		
		if skipEdit:
			continue

		#- Append edit to interp and loop to next.
		interp.edits.append(currentEdit)
		previousEdit = currentEdit
	
	return interp

#--- Compiles the interp data into raw string format for ini-extension syntax.
func interp_to_raw(interp): # interp = {}
	var raw = ""
	for x in range(interp.edits.size()):
		var edit = interp.edits[x]
		match edit.type:
			-1: #- Comment
				for i in range(edit.comments.size()):
					raw += ";" + edit.comments[i]
					if not i == edit.comments.size() - 1:
						raw += "\n"
			0: #- Keyword
				#- Handle name
				if not edit.name == "" || not edit.comments.size() == 0:
					raw += ";" + "[" + edit.name + "]"
					if edit.comments.size() > 0:
						raw += edit.comments[0] + "\n"
					else:
						raw += "\n"
					for i in range(edit.comments.size()):
						if i == 0:
							continue
						raw += ";" + edit.comments[i] + "\n"

				#- Handle Keyword definition.
				raw += "Keyword = "
				raw += edit.objectId.value
				match edit.objectId.type:
					1,2: #- All types that include a variation of '~MyMod.esp'
						raw += "~" + edit.objectId.source
				
				#- Handle assign type
				raw += "|" + get_type_name(edit.itemType)
				
				#- Handle filters
				if edit.stringAndFormFilters.size() == 0:
					raw += "|NONE"
				else:
					raw += "|"
					for i in range(edit.stringAndFormFilters.size()):
						if i > 0:
							raw += ","
						raw += edit.stringAndFormFilters[i]
				
				#- Handle traits
				if edit.traitFilters.size() == 0:
					raw += "|NONE"
				else:
					raw += "|"
					for i in range(edit.traitFilters.size()):
						if i > 0:
							raw += ","
						raw += edit.traitFilters[i]
				
				#- Handle chance
				raw += "|" + str(edit.chance)

				#- Clean unused filters
				raw = raw.replace("|NONE|NONE|100", "")
				raw = raw.replace("|NONE|100", "")
				raw = raw.replace("|100", "")
		
		#- Append newlines from edit
		if x == interp.edits.size() - 1:
			raw += "\n"
		else:
			for i in edit.newlines:
				raw += "\n"
	return raw

#--- Intercepts the filesave process to alter the file name before it is saved.
func alter_save_name(originalName:String):
	if not "_KID" in originalName:
		originalName += "_KID"
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
	var edit = interp.edits[index]
	var eName = ""
	match edit.type:
		-1: #- (-1)Comment
			eName += str(edit.lineNumber - edit.comments.size() + 1) + "~" if edit.comments.size() > 1 else ""
			eName += str(edit.lineNumber) + " "
			eName += "Comment: " + edit.comments[0]
			return eName
		0: #- (0)Keyword
			eName += str(edit.lineNumber - edit.comments.size()) + "~" if (edit.comments.size() > 0 && edit.comments[0] != "") || edit.name != "" else ""
			eName += str(edit.lineNumber) + " "
			eName += get_type_name(edit.itemType) + ": "
	if edit.name == "":
		eName += edit.objectId.value
	else:
		eName += edit.name
	return eName

#--- Called by the system to remove an edit from circulation.
func delete_edit(index, interp):
	interp.edits.remove(index)
	pass

#--- CUSTOM: Creates a blank edit to populate with data.
func create_new_edit():
	var edit = {
		"newlines":1, #- For how many empty lines after the edit.
		"lineNumber":-1, #- For which line the edit originates from.
		"type":-1,
		"name":"",
		"comments":[],
		"objectId":{
			"type":0, #- Types: (0)editorID, (1)esp/esm[6digits], (2)esl[3digits]
			"value":"", #- Erase leading 0's if there are any. -> {00}65AFD
			"source":""
		},
		"itemType":-1,
		"stringAndFormFilters":[],
		"traitFilters":[],
		"chance":100
	}
	return edit

#--- CUSTOM: Returns the distribution type's name.
func get_type_name(itemType:int):
	match itemType:
		-1:
			return "ERROR"
		0:
			return "Weapon"
		1:
			return "Armor"
		2:
			return "Ammo"
		3:
			return "Magic Effect"
		4:
			return "Potion"
		5:
			return "Scroll"
		6:
			return "Location"
		7:
			return "Ingredient"
		8:
			return "Book"
		9:
			return "Misc Item"
		10:
			return "Key"
		11:
			return "Soul Gem"
		12:
			return "Spell"
		13:
			return "Activator"
		14:
			return "Flora"
		15:
			return "Furniture"
		16:
			return "Race"
		17:
			return "Talking Activator"
		18:
			return "Enchantment"

#--- CUSTOM: Handles view-menu option selections.
func handle_view(selected):
	match selected:
		kidOption:
			Functions.open_link("https://www.nexusmods.com/skyrimspecialedition/mods/55728")
			console_manager.generate("Opening link to KID's mod page...", Globals.green)
	pass
