@tool
@icon("res://addons/controller_icons/objects/controller_texture_icon.svg")
extends Texture2D
class_name ControllerIconTexture
## [Texture2D] proxy for displaying controller icons
##
## A 2D texture representing a controller icon. The underlying system provides
## a [Texture2D] that may react to changes in the current input method, and also detect the user's controller type.
## Specify the [member path] property to setup the desired icon and behavior.[br]
## [br]
## For a more technical overview, this resource functions as a proxy for any
## node that accepts a [Texture2D], redefining draw commands to use an
## underlying plain [Texture2D], which may be swapped by the remapping system.[br]
## [br]
## This resource works out-of-the box with many default nodes, such as [Sprite2D],
## [Sprite3D], [TextureRect], [RichTextLabel], and others. If you are
## integrating this resource on a custom node, you will need to connect to the
## [signal Resource.changed] signal to properly handle changes to the underlying
## texture. You might also need to force a redraw with methods such as
## [method CanvasItem.queue_redraw].
##
## @tutorial(Online documentation): https://github.com/rsubtil/controller_icons/?tab=readme-ov-file

## A path describing the desired icon. This is a generic path that can be one
## of three different types:
## [br][br]
## [b]- Input Action[/b]: Specify the exact name of an existing input action. The
## icon will be swapped automatically depending on whether the keyboard/mouse or the
## controller is being used. When using a controller, it also changes according to
## the controller type.[br][br]
## [i]This is the recommended approach, as it will handle all input methods
## automatically, and supports any input remapping done at runtime[/i].
## [codeblock]
## # "Enter" on keyboard, "Cross" on Sony,
## # "A" on Xbox, "B" on Nintendo
## path = "ui_accept"
## [/codeblock]
## [b]- Joypad Path[/b]: Specify a generic joypad path resembling the layout of a
## Xbox 360 controller, starting with the [code]joypad/[/code] prefix. The icon will only
## display controller icons, but it will still change according to the controller type.
## [codeblock]
## # "Square" on Sony, "X" on Xbox, "Y" on Nintendo
## path = "joypad/x"
## [/codeblock]
## [b]- Specific Path[/b]: Specify a direct asset path from the addon assets.
## With this path type, there is no dynamic remapping, and the icon will always
## remain the same. The path to use is the path to an icon file, minus the base
## path and extension.
## [codeblock]
## # res://addons/controller_icons/assets/steam/gyro.png
## path = "steam/gyro"
## [/codeblock]
@export var path : String = "":
	set(_path):
		path = _path
		_load_texture_path()

enum ForceType {
	KEYBOARD_MOUSE, ## Icon will always show the keyboard/mouse action.
	CONTROLLER, ## Icon will always show the controller action. 
}

## The icon show either the keyboard/mouse or controller icon
##[br][br]
## This is only relevant for paths using input actions, and has no effect on
## other scenarios.
@export var force_type : ForceType = ForceType.KEYBOARD_MOUSE:
	set(_force_type):
		force_type = _force_type
		_load_texture_path()

## To which player is this icon attached
## This attempt to show buttons of the device of the player
## In case the control is not in the list 
## It will fallback to settings.tres joypad_fallback
##[br][br]
## You must update player devices to get the correct joypad of them.
## In case you don't update the devices it will use the default list [0,1,2,...,7]
## [codeblock]
## # Update the player device
## ControllerIcons.update_player_device(ControllerIcons.PlayerDevices.Player1, device)
## [/codeblock]
@export var player : ControllerIcons.PlayerDevices = 0:
	set(_player):
		player = _player
		_load_texture_path()

@export_subgroup("Text Rendering")
## Custom LabelSettings. If set, overrides the addon's global label settings.
@export var custom_label_settings : LabelSettings:
	set(_custom_label_settings):
		custom_label_settings = _custom_label_settings
		_load_texture_path()
		# Call _textures setter, which handles signal connections for label settings
		_textures = _textures


## Returns a text representation of the displayed icon, useful for TTS
## (text-to-speech) scenarios.
## [br][br]
## This takes into consideration the currently displayed icon, and will thus be
## different if the icon is from keyboard/mouse or controller. It also takes
## into consideration the controller type, and will thus use native button
## names (e.g. [code]A[/code] for Xbox, [code]Cross[/code] for PlayStation, etc).
func get_tts_string() -> String:
	if force_type:
		return ControllerIcons.parse_path_to_tts(path, force_type )
	else:
		return ControllerIcons.parse_path_to_tts(path)


var _textures : Array[Texture2D]:
	set(__textures):
		# UPGRADE: In Godot 4.2, for-loop variables can be
		# statically typed:
		# for tex:Texture in __textures:
		for tex in __textures:
			if tex and tex.is_connected("changed", _reload_resource):
				tex.disconnect("changed", _reload_resource)

		if _label_settings and _label_settings.is_connected("changed", _on_label_settings_changed):
			_label_settings.disconnect("changed", _on_label_settings_changed)

		_textures = __textures
		_label_settings = null
		if _textures and _textures.size() > 1:
			_label_settings = custom_label_settings
			if not _label_settings:
				_label_settings = ControllerIcons._settings.custom_label_settings
			if not _label_settings:
				_label_settings = LabelSettings.new()
			_label_settings.connect("changed", _on_label_settings_changed)
			_font = ThemeDB.fallback_font if not _label_settings.font else _label_settings.font
			_on_label_settings_changed()
		# UPGRADE: In Godot 4.2, for-loop variables can be
		# statically typed:
		# for tex:Texture in __textures:
		for tex in __textures:
			if tex:
				tex.connect("changed", _reload_resource)

var _font : Font
var _label_settings : LabelSettings
var _text_size : Vector2

func _on_label_settings_changed():
	_font = ThemeDB.fallback_font if not _label_settings.font else _label_settings.font
	_text_size = _font.get_string_size("+", HORIZONTAL_ALIGNMENT_LEFT, -1, _label_settings.font_size)
	_reload_resource()

func _reload_resource():
	_dirty = true
	emit_changed()

func _load_texture_path_impl():
	var textures : Array[Texture2D] = []
	var device = _get_player_device()
	
	if ControllerIcons.is_node_ready() and device != -1:
		var input_type = force_type 
		if ControllerIcons.get_path_type(path) == ControllerIcons.PathType.INPUT_ACTION:
			var event := ControllerIcons.get_matching_event(path, input_type, device)
			textures.append_array(ControllerIcons.parse_event_modifiers(event))
		var tex := ControllerIcons.parse_path(path, input_type, device)
		if tex:
			textures.append(tex)
	_textures = textures
	_reload_resource()

func _get_player_device() -> int:
	if ControllerIcons.player_controllers[player] != -1:
		return ControllerIcons.player_controllers[player]
	else:
		return ControllerIcons._default_player_controllers[player]

func _load_texture_path():
	# Ensure loading only occurs on the main thread
	if OS.get_thread_caller_id() != OS.get_main_thread_id():
		# In Godot 4.3, call_deferred no longer makes this function
		# execute on the main thread due to changes in resource loading.
		# To ensure this, we instead rely on ControllerIcons for this
		ControllerIcons._defer_texture_load(_load_texture_path_impl)
	else:
		_load_texture_path_impl()

func _init():
	ControllerIcons.reload.connect(_load_texture_path)

#region "Draw functions"
const _NULL_SIZE := 2

func _get_width() -> int:
	var ret := _textures.reduce(func(accum: int, texture: Texture2D):
		if texture:
			return accum + texture.get_width()
		return accum
	, 0)
	if _label_settings:
		ret += max(0, _textures.size()-1) * _text_size.x
	# If ret is 0, return a size of 2 to prevent triggering engine checks
	# for null sizes. The correct size will be set at a later frame.
	return ret if ret > 0 else _NULL_SIZE

func _get_height() -> int:
	var ret := _textures.reduce(func(accum: int, texture: Texture2D):
		if texture:
			return max(accum, texture.get_height())
		return accum
	, 0)
	if _label_settings and _textures.size() > 1:
		ret = max(ret, _text_size.y)
	# If ret is 0, return a size of 2 to prevent triggering engine checks
	# for null sizes. The correct size will be set at a later frame.
	return ret if ret > 0 else _NULL_SIZE

func _has_alpha() -> bool:
	return _textures.any(func(texture: Texture2D):
		return texture.has_alpha()
	)

func _is_pixel_opaque(x, y) -> bool:
	# TODO: Not exposed to GDScript; however, since this seems to be used for editor stuff, it's
	# seemingly fine to just report all pixels as opaque. Otherwise, mouse picking for Sprite2D
	# stops working.
	return true

func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool):
	var position := pos

	for i in range(_textures.size()):
		var tex:Texture2D = _textures[i]
		if !tex: continue

		if i != 0:
			# Draw text char '+'
			var font_position := Vector2(
				position.x,
				position.y + (get_height() - _text_size.y) / 2.0
			)
			_draw_text(to_canvas_item, font_position, "+")
			position.x += _text_size.x

		tex.draw(to_canvas_item, position, modulate, transpose)
		position.x += tex.get_width()

func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool):
	var position := rect.position
	var width_ratio := rect.size.x / _get_width()
	var height_ratio := rect.size.y / _get_height()

	for i in range(_textures.size()):
		var tex:Texture2D = _textures[i]
		if !tex: continue

		if i != 0:
			# Draw text char '+'
			var font_position := Vector2(
				position.x + (_text_size.x * width_ratio) / 2 - (_text_size.x / 2),
				position.y + (rect.size.y - _text_size.y) / 2.0
			)
			_draw_text(to_canvas_item, font_position, "+")
			position.x += _text_size.x * width_ratio

		var size := tex.get_size() * Vector2(width_ratio, height_ratio)
		tex.draw_rect(to_canvas_item, Rect2(position, size), tile, modulate, transpose)
		position.x += size.x

func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool):
	var position := rect.position
	var width_ratio := rect.size.x / _get_width()
	var height_ratio := rect.size.y / _get_height()

	for i in range(_textures.size()):
		var tex:Texture2D = _textures[i]
		if !tex: continue

		if i != 0:
			# Draw text char '+'
			var font_position := Vector2(
				position.x + (_text_size.x * width_ratio) / 2 - (_text_size.x / 2),
				position.y + (rect.size.y - _text_size.y) / 2.0
			)
			_draw_text(to_canvas_item, font_position, "+")
			position.x += _text_size.x * width_ratio

		var size := tex.get_size() * Vector2(width_ratio, height_ratio)
		var src_rect_ratio := Vector2(
			tex.get_width() / float(_get_width()),
			tex.get_height() / float(_get_height())
		)
		var tex_src_rect := Rect2(
			src_rect.position * src_rect_ratio,
			src_rect.size * src_rect_ratio
		)

		tex.draw_rect_region(to_canvas_item, Rect2(position, size), tex_src_rect, modulate, transpose, clip_uv)
		position.x += size.x

func _draw_text(to_canvas_item: RID, font_position: Vector2, text: String):
	font_position.y += _font.get_ascent(_label_settings.font_size)
	
	if _label_settings.shadow_color.a > 0:
		_font.draw_string(to_canvas_item, font_position + _label_settings.shadow_offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1, _label_settings.font_size, _label_settings.shadow_color)
		if _label_settings.shadow_size > 0:
			_font.draw_string_outline(to_canvas_item, font_position + _label_settings.shadow_offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1, _label_settings.font_size, _label_settings.shadow_size, _label_settings.shadow_color)
	if _label_settings.outline_color.a > 0 and _label_settings.outline_size > 0:
			_font.draw_string_outline(to_canvas_item, font_position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, _label_settings.font_size, _label_settings.outline_size, _label_settings.outline_color)
	_font.draw_string(to_canvas_item, font_position, text, HORIZONTAL_ALIGNMENT_CENTER, -1, _label_settings.font_size, _label_settings.font_color)

var _helper_viewport : Viewport
var _is_stitching_texture : bool = false
func _stitch_texture():
	if _textures.is_empty():
		return

	_is_stitching_texture = true

	var font_image : Image
	if _textures.size() > 1:
		# Generate a viewport to draw the text
		_helper_viewport = SubViewport.new()
		# FIXME: We need a 3px margin for some reason
		_helper_viewport.size = _text_size + Vector2(3, 0)
		_helper_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		_helper_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
		_helper_viewport.transparent_bg = true

		var label := Label.new()
		label.label_settings = _label_settings
		label.text = "+"
		label.position = Vector2.ZERO
		_helper_viewport.add_child(label)

		ControllerIcons.add_child(_helper_viewport)
		await RenderingServer.frame_post_draw
		font_image = _helper_viewport.get_texture().get_image()
		ControllerIcons.remove_child(_helper_viewport)
		_helper_viewport.free()

	var position := Vector2i(0, 0)
	var img : Image
	for i in range(_textures.size()):
		if !_textures[i]: continue

		if i != 0:
			# Draw text char '+'
			var region := font_image.get_used_rect()
			var font_position := Vector2i(
				position.x,
				position.y + (get_height() - region.size.y) / 2
			)
			img.blit_rect(font_image, region, font_position)
			position.x += ceili(region.size.x)

		var texture_raw := _textures[i].get_image()
		texture_raw.decompress()
		if not img:
			img = Image.create(_get_width(), _get_height(), true, texture_raw.get_format())

		img.blit_rect(texture_raw, Rect2i(0, 0, texture_raw.get_width(), texture_raw.get_height()), position)
		position.x += texture_raw.get_width()

	_is_stitching_texture = false
	_dirty = false
	_texture_3d = ImageTexture.create_from_image(img)
	emit_changed()

# This is necessary for 3D sprites, as the texture is assigned to a material, and not drawn directly.
# For multi prompts, we need to generate a texture
var _dirty := true
var _texture_3d : Texture
func _get_rid():
	if _dirty:
		if not _is_stitching_texture:
			# FIXME: Function may await, but because this is an internal engine call, we can't do anything about it.
			# This results in a one-frame white texture being displayed, which is not ideal. Investigate later.
			_stitch_texture()
			if _is_stitching_texture:
				return 0
		else:
			return 0
	return _texture_3d.get_rid() if not _textures.is_empty() else 0

#endregion
