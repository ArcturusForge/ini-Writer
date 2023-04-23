extends Control

#-- Constants
const my_id = "window"

#-- Window Parent
onready var windows_parent = $"../../Windows"

#-- Enabled on all window activation.
var input_block

#-- Windows
var windows = {}

#-- Dynamic Vars
var activeWindow
var windowHistory = []

func jump_start():
	Globals.set_manager(my_id, self)
	input_block = $"../../Windows/InputBlock"
	
	#- Disable any active windows on boot.
	for window in windows.values():
		window.visible = false
	pass

func activate_window(windowId, data=null, storeHistory=true):
	if windows.has(windowId):
		input_block.visible = true
		var hasHist = false
		if windowHistory.size() > 0:
			hasHist = true
		disable_window(false, true)
		activeWindow = windows[windowId]
		activeWindow.hasHistory = hasHist
		activeWindow.visible = true
		activeWindow._enable(data)
		if storeHistory:
			add_to_history(windowId, data)
	pass

func disable_window(disableBlock = true, isReplaced=false):
	if not activeWindow == null:
		if disableBlock:
			disable_input_block()
		activeWindow._disable()
		activeWindow.visible = false
		activeWindow = null
	if not isReplaced:
		windowHistory.clear()
	pass

func disable_input_block():
	input_block.visible = false
	pass

func register_window(id, window, defaultState = false):
	window.window_manager = self
	window._create()
	windows[id] = window
	if defaultState == true:
		activate_window(id)
	else:
		window.visible = false
	pass

func add_to_history(id:String, data):
	if windowHistory.size() > 4:
		windowHistory.remove(0)
	windowHistory.append({
		"id":id,
		"data":data
	})

func activate_previous():
	if windowHistory.size() == 0:
		printerr("Attempting to open a previous window when there are none!")
		return
	windowHistory.remove(windowHistory.size() - 1)
	var history = windowHistory[windowHistory.size() - 1]
	activate_window(history.id, history.data, false)
