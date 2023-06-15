extends Control

#- Splits text content by line and tries to match each line to a type.
#- type_dict structure ==> [{symbol:String=>Value:int}]
#- return structure ==> [{type:int, line:String, line_number:int}]
#- Automatic types: [-2=>Empty line], [-9=>Untyped line]
func split_and_define_lines(text:String, type_dict:Dictionary, line_number_offset:int = 1):
	#- Split text into lines.
	var lines = text.split("\n")
	if lines.size() == 0:
		return []
	
	var defined = []
	for i in range(lines.size()):
		var line = lines[i]
		var foundSymbol = false
		for symbol in type_dict.keys():
			if symbol in line:
				foundSymbol = true
				defined.append({
					"type": type_dict[symbol],
					"line": line,
					"line_number": i + line_number_offset
				})
				break
		
		if foundSymbol:
			continue
		
		#- If this point is reached then the line had no recognized symbols.
		defined.append({
			"type": -2 if line == "" else -9,
			"line": line,
			"line_number": i
			})
	
	#- Return the typed lines.
	return defined
