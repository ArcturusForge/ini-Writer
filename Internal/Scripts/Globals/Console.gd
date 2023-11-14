extends Node

func post(msg:String)->void:
	Globals.get_manager("console").post(msg)
	

func postwrn(msg:String)->void:
	Globals.get_manager("console").postwrn(msg)
	

func posterr(msg:String)->void:
	Globals.get_manager("console").posterr(msg)
	

func postconf(msg:String)->void:
	Globals.get_manager("console").generate(msg,Globals.green)
	

func generate(msg:String, colorHex:String)->void:
	Globals.get_manager("console").generate(msg,colorHex)
	
