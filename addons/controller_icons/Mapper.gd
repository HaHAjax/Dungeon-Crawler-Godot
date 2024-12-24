extends Node
class_name ControllerMapper

func _convert_joypad_path(path: String, device: int, fallback: ControllerSettings.Devices) -> String:
	match _get_joypad_type(device, fallback):
		ControllerSettings.Devices.PS3:
			return _convert_joypad_to_ps3(path)
		ControllerSettings.Devices.STEAM:
			return _convert_joypad_to_steam(path)
		ControllerSettings.Devices.SWITCH:
			return _convert_joypad_to_switch(path)
		ControllerSettings.Devices.XBOX360:
			return _convert_joypad_to_xbox360(path)
		_:
			return ""

func _get_joypad_type(device, fallback):
	# If we have not device, we use fallback, this to avoid crash errors
	var available = Input.get_connected_joypads()
	if available.is_empty():
		# Here we use fallback, but due to errors we call xbox360
		return fallback
	
	var controller_name = Input.get_joy_name(device)
	# Todos los play station caben en uno solo
	if "PS3 Controller" in controller_name or "PS4 Controller" in controller_name or \
		"DUALSHOCK 4" in controller_name or "PS5 Controller" in controller_name or \
		"DualSense" in controller_name:
		return ControllerSettings.Devices.PS3
	elif "Steam Controller" in controller_name:
		return ControllerSettings.Devices.STEAM
	elif "Switch Controller" in controller_name or \
		"Switch Pro Controller" in controller_name:
		return ControllerSettings.Devices.SWITCH
	elif "Xbox 360 Controller" in controller_name or\
		"Xbox One" in controller_name or \
		"X-Box One" in controller_name or \
		"Xbox Wireless Controller" in controller_name or \
		"Xbox Series" in controller_name:
		return ControllerSettings.Devices.XBOX360
	else:
		# Here we use fallback, but due to errors we call xbox360
		return fallback

func _convert_joypad_to_playstation(path: String):
	match path.substr(path.find("/") + 1):
		"a":
			return path.replace("/a", "/cross")
		"b":
			return path.replace("/b", "/circle")
		"x":
			return path.replace("/x", "/square")
		"y":
			return path.replace("/y", "/triangle")
		"lb":
			return path.replace("/lb", "/l1")
		"rb":
			return path.replace("/rb", "/r1")
		"lt":
			return path.replace("/lt", "/l2")
		"rt":
			return path.replace("/rt", "/r2")
		_:
			return path

func _convert_joypad_to_ps3(path: String):
	return _convert_joypad_to_playstation(path.replace("joypad", "ps3"))

func _convert_joypad_to_steam(path: String):
	path = path.replace("joypad", "steam")
	match path.substr(path.find("/") + 1):
		"r_stick_click":
			return path.replace("/r_stick_click", "/right_track_center")
		"select":
			return path.replace("/select", "/back")
		"home":
			return path.replace("/home", "/system")
		"dpad":
			return path.replace("/dpad", "/left_track")
		"dpad_up":
			return path.replace("/dpad_up", "/left_track_up")
		"dpad_down":
			return path.replace("/dpad_down", "/left_track_down")
		"dpad_left":
			return path.replace("/dpad_left", "/left_track_left")
		"dpad_right":
			return path.replace("/dpad_right", "/left_track_right")
		"l_stick":
			return path.replace("/l_stick", "/stick")
		"r_stick":
			return path.replace("/r_stick", "/right_track")
		_:
			return path

func _convert_joypad_to_switch(path: String):
	path = path.replace("joypad", "switch")
	match path.substr(path.find("/") + 1):
		"a":
			return path.replace("/a", "/b")
		"b":
			return path.replace("/b", "/a")
		"x":
			return path.replace("/x", "/y")
		"y":
			return path.replace("/y", "/x")
		"lb":
			return path.replace("/lb", "/l")
		"rb":
			return path.replace("/rb", "/r")
		"lt":
			return path.replace("/lt", "/zl")
		"rt":
			return path.replace("/rt", "/zr")
		"select":
			return path.replace("/select", "/minus")
		"start":
			return path.replace("/start", "/plus")
		"share":
			return path.replace("/share", "/square")
		_:
			return path

func _convert_joypad_to_xbox360(path: String):
	path = path.replace("joypad", "xbox360")
	match path.substr(path.find("/") + 1):
		"select":
			return path.replace("/select", "/back")
		_:
			return path

func _convert_joypad_to_xbox_modern(path: String):
	match path.substr(path.find("/") + 1):
		"select":
			return path.replace("/select", "/view")
		"start":
			return path.replace("/start", "/menu")
		_:
			return path

func _convert_joypad_to_xboxone(path: String):
	return _convert_joypad_to_xbox_modern(path.replace("joypad", "xboxone"))

func _convert_joypad_to_xboxseries(path: String):
	return _convert_joypad_to_xbox_modern(path.replace("joypad", "xboxseries"))

func _convert_joypad_to_steamdeck(path: String):
	path = path.replace("joypad", "steamdeck")
	match path.substr(path.find("/") + 1):
		"lb":
			return path.replace("/lb", "/l1")
		"rb":
			return path.replace("/rb", "/r1")
		"lt":
			return path.replace("/lt", "/l2")
		"rt":
			return path.replace("/rt", "/r2")
		"select":
			return path.replace("/select", "/square")
		"start":
			return path.replace("/start", "/menu")
		"home":
			return path.replace("/home", "/steam")
		"share":
			return path.replace("/share", "/dots")
		_:
			return path
