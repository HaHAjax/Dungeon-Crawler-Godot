@tool
extends Resource
class_name ControllerSettings

enum Devices {
	PS3,
	STEAM,
	SWITCH,
	XBOX360,
	STEAM_DECK
}

## General addon settings
@export_subgroup("General")

## Controller type to fallback to if automatic
## controller detection fails
@export var joypad_fallback : Devices = Devices.PS3

## Settings related to advanced custom assets usage and remapping
@export_subgroup("Custom assets")

## Custom asset lookup folder for custom icons
@export_dir var custom_asset_dir : String = ""

## Custom generic joystick mapper script
@export var custom_mapper : Script

## Custom icon file extension
@export var custom_file_extension : String = ""

## Custom settings related to any text rendering required on prompts
@export_subgroup("Text Rendering")

## Custom LabelSettings. If unset, uses engine default settings.
@export var custom_label_settings : LabelSettings
