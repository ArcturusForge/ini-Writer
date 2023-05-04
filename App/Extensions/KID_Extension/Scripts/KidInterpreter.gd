extends Node

#--- Determines wether ini file matches extension use-case.
func data_matched(raw:String, fileName:String):
	if "_KID" in fileName:
		return true
	else:
		return false

#--- Called by system when the extension is enabled.
func enable():
	pass

#--- Called by system when the extension is disabled.
func disable():
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
	var currentEdit = create_new_edit()
	var previousEdit = null

	#- Loops through the parsed lines for converting into interp data.
	for parsed in parsed_lines:
		#- Assign type before handling it.
		currentEdit.type = parsed.type
		currentEdit.lineNumber = parsed.line_number
		var line = parsed.line

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
								var id = currentFilter.get_slice("x", 1) if "0x" in currentFilter else currentFilter.get_slice("x", 1)
								if ".esm" in currentFilter || ".esp" in currentFilter:
									#- Comes from a different plugin than skyrim and the original dlc.
									currentEdit.objectId.type = 1
									currentEdit.objectId.value = id.get_slice("~", 0)
								elif ".esl" in currentFilter:
									#- Comes from a light plugin.
									currentEdit.objectId.type = 2
									currentEdit.objectId.value = id.get_slice("~", 0)
								else:
									#- Comes from skyrim or original dlc.
									currentEdit.objectId.type = 3
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
					continue
				#- Line is a multi-line comment belonging to a KID edit.
				elif not editComment == null:
					editComment.comments.append(line.erase(0, 1))
					continue
				#- Line is a standalone comment.
				else:
					currentEdit.comments.append(line.erase(0, 1))
			-2:#- Empty line
				if previousEdit == null:
					continue
				previousEdit.newlines += 1
				continue
			-9:#- Untyped
				continue
		
		#--- End: Parse the edit
		
		#- Append edit to interp and loop to next.
		interp.edits.append(currentEdit)
		previousEdit = currentEdit
	
	return interp

#--- Compiles the interp data into raw string format for ini-extension syntax.
func interp_to_raw(interp): # interp = {}
	return ""

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
	var eName = str(edit.lineNumber) + " "
	match edit.type:
		-1: #- (-1)Comment
			eName += "Comment: " + edit.comment
			return eName
		0: #- (0)Spell
			match edit.itemType:
				0:
					eName += "Weapon: "
				1:
					eName += "Armor: "
				2:
					eName += "Ammo: "
				3:
					eName += "Magic Effect: "
				4:
					eName += "Potion: "
				5:
					eName += "Scroll: "
				6:
					eName += "Location: "
				7:
					eName += "Ingredient: "
				8:
					eName += "Book: "
				9:
					eName += "Misc Item: "
				10:
					eName += "Key: "
				11:
					eName += "Soul Gem: "
				12:
					eName += "Spell: "
				13:
					eName += "Activator: "
				14:
					eName += "Flora: "
				15:
					eName += "Furniture: "
				16:
					eName += "Race: "
				17:
					eName += "Talking Activator: "
				18:
					eName += "Enchantment: "
	if edit.name == "":
		eName += edit.objectId.value
	else:
		eName += edit.name
	return eName

#--- Called by the system to remove an edit from circulation.
func delete_edit(index, interp):
	interp.edits.remove(index)
	pass

#--- Custom: Creates a blank edit to populate with data.
func create_new_edit():
	var edit = {
		"newlines":1, #- For how many empty lines after the edit.
		"lineNumber":-1, #- For which line the edit originates from.
		"type":-1,
		"name":"",
		"comments":[],
		"objectId":{
			"type":0, #- Types: (0)editorID, (1)esp/esm[6digits], (2)esl[3digits], (3)skyrim/original dlc[6digits]
			"value":"", #- Erase leading 0's if there are any. -> {00}65AFD
			"source":""
		},
		"itemType":-1,
		"stringAndFormFilters":[],
		"traitFilters":[],
		"chance":100
	}
	return edit
