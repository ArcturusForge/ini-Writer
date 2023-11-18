extends Node

var unzipper = preload("res://addons/gdunzip/gdunzip.gd")

func import_resource_zip(zipPath:String)->void:
	var uz = unzipper.new()
	var d = Directory.new()
	if uz.load(zipPath):
		for fPath in uz.files:
			var dat = uz.files[fPath]
			if dat.compression_method > -1:
				var p:String = (OS.get_executable_path().get_base_dir() + "/" + ProjectSettings.globalize_path(Globals.localResouPath) + "/" + fPath) if Functions.is_app() else Globals.localResouPath + "/" + fPath
				d.make_dir_recursive(p.get_base_dir())
				var f = File.new()
				f.open(p, File.WRITE)
				f.store_buffer(uz.uncompress(fPath))
				f.close()
		Console.postconf("Successfully imported resource package.")
	else:
		Console.posterr("Unable to load zip file")
	

func import_extension_zip(zipPath:String)->void:
	var uz = unzipper.new()
	var folders:PoolStringArray
	var files:PoolStringArray
	var jsons:PoolStringArray
	
	if uz.load(zipPath):
		for fPath in uz.files:
			var dat = uz.files[fPath]
			if dat.compression_method == -1: #- Probably a folder.
				folders.append(dat.file_name)
			else : #--------------------------- Probably a compressed file.
				if dat.file_name.ends_with(".json"):
					jsons.append(dat.file_name)
					files.append(dat.file_name)
				else:
					files.append(dat.file_name)
		
		if jsons.size() >= 1:
			var index:=-1
			for i in range(jsons.size()):
				var uncomp:PoolByteArray = uz.uncompress(jsons[i])
				var data = parse_json(uncomp.get_string_from_ascii())
				if !data.has("version") && !data.has("extension") && !data.has("interpreterScript") && !data.has("editorInterface"):
					continue
				else:
					index = i
			if index > -1:
				_process_extension_import(folders, files, uz)
				return
	else:
		Console.posterr("Unable to load zip file")
	Console.posterr("Zip file is not an ini-Writer extension.")
	

func _process_extension_import(folders:PoolStringArray, files:PoolStringArray, uz)->void:
	var ep = (OS.get_executable_path().get_base_dir() + "/" + ProjectSettings.globalize_path(Globals.localExtenPath)) if Functions.is_app() else Globals.localExtenPath
	var errorFree := true
	for folder in folders:
		var path = ep + "/" + folder
		var d = Directory.new()
		if !d.dir_exists(path):
			if d.make_dir_recursive(path) > 0:
				errorFree = false
	
	for file in files:
		var path = ep + "/" + file
		var f = File.new()
		if f.open(path, File.WRITE) == 0:
			f.store_buffer(uz.uncompress(file))
			f.close()
		else:
			errorFree = false
	if errorFree:
		Console.postconf("Successfully imported extension package.")
	else:
		Console.posterr("An error was encountered when importing extension.")
	
