extends Control

func parse_lines(text:String, symbols:Array, line_number_offset:int=1)->Array:
	#- Split text into lines.
	var lines := text.split("\n")
	if lines.size() == 0:
		return []
	
	var parsed = []
	for i in range(lines.size()):
		var curLine :String = lines[i]	
		var validSymbols := []
		
		if curLine == "":
			var res = create_result(curLine, i + line_number_offset, -8)
			parsed.append(res)
			continue
		
		for curSymbol in symbols:
			#- Start with simple filter.
			var skip = false
			for excl in curSymbol.exclusionSymbols:
				if excl in curLine:
					skip = true
					break
			
			if skip:
				continue
			
			#- Continue with precise check.
			if curLine.begins_with(curSymbol.startSymbol):
				var incSkip = false
				for symb in curSymbol.inclusionSymbols:
					if not symb in curLine:
						incSkip = true
						break
				
				if incSkip:
					continue
				
				if curSymbol.endSymbol != "" && curLine.ends_with(curSymbol.endSymbol):
					validSymbols.append(curSymbol)
				elif curSymbol.endSymbol == "":
					validSymbols.append(curSymbol)
			
		
		if validSymbols.size() == 1: #- Simple search identified a type.
			var res = create_result(curLine, i + line_number_offset, validSymbols[0].symbolType)
			parsed.append(res)
		elif validSymbols.size() > 1: #- Symbol filters are too loose
			var res = create_result(curLine, i + line_number_offset, -9)
			parsed.append(res)
			Console.postwrn("Extension has line parsing filters that are unspecific and has resulted in a line succeeding multiple type checks!")
			Console.postwrn("Can occur when one symbol appears in another without exclusion rules being applied.")
		elif validSymbols.size() == 0: #- Unidentified line type.
			var res = create_result(curLine, i + line_number_offset, -9)
			parsed.append(res)
	return parsed
	

func create_result(line:String, lineNumber:int, type:int)->Dictionary:
	return {
		"line":line,
		"lineNumber":lineNumber,
		"type":type
	}

func create_symbol(symbolType:int, startSymbol:String, endSymbol:="", inclusionSymbols:PoolStringArray=[], exlusionSymbols:PoolStringArray=[])->Dictionary:
	return {
		"symbolType":symbolType,
		"startSymbol":startSymbol,
		"endSymbol":endSymbol,
		"inclusionSymbols":inclusionSymbols,
		"exclusionSymbols":exlusionSymbols
	}
	
