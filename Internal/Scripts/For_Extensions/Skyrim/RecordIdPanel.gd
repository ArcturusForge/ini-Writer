extends PanelContainer

export var useSelector:=true
export var selectorBypassedDefault:=0

onready var id_panel = $VBoxContainer/IdPanel

func _ready():
	id_panel.useSelector = self.useSelector
	id_panel.selectorBypassedDefault = self.selectorBypassedDefault
	id_panel._ready()
	

func put(id:String)->void:
	id_panel.put(id)
	

func grab()->String:
	return id_panel.grab()
	
