extends CharacterBody3D

enum PlayerStates
{
	Enter = -1,
	Idle,
	Moving,
	Rolling
}

var curr_state: PlayerStates = PlayerStates.Idle
var prev_state: PlayerStates = PlayerStates.Enter

@onready var rollAnimationPlayer: AnimationPlayer = $RollAnimation
@onready var rollAnimation: Animation = rollAnimationPlayer.get_animation("RollAnimation")
@onready var rollParticles: GPUParticles3D = $RollParticles

@export_group("Misc. stats")
@export_range(0, 25, 0.1) var moveSpeed: float = 5.0
@export_group("Roll Stats")
@export_range(0, 100, 0.5) var rollSpeed: float = 20.0
@export_range(0, 10, 0.1) var rollDuration: float = 0.3
@export_range(0, 10, 0.1) var rollCooldown: float = 1.0

var moveDirection: Vector3 = Vector3.ZERO
var lookDirection: Vector3 = Vector3.ZERO
var rollDirection: Vector3 = Vector3.ZERO

var isActivelyRolling: bool = false
var timerRoll: float = 0
var timerRollCooldown: float = 0
var lookAmount: float = 0
var rollLookAmount: float = 0

var inputMoveDirection: Vector2 = Vector2.ZERO
var inputRollDirection: Vector2 = Vector2.ZERO
var inputDoRollButton: bool = false

var movePos: Vector3 = Vector3.ZERO

func _physics_process(delta):
	_update_states()
	_update_variables(delta)
	_update_inputs()
	
	if curr_state != prev_state:
		_exit_state(prev_state, delta)
		_transition_states(prev_state, curr_state, delta)
		_enter_state(curr_state, delta)
	
	_update_active_state(delta)
	_rotate_player(delta)
	
	prev_state = curr_state

func _update_active_state(delta):
	match curr_state:
		PlayerStates.Idle:
			if shouldRollCooldownCount():
				_do_roll_cooldown(delta)
		PlayerStates.Moving:
			_move_player()
			_update_rotation_variables()
			if shouldRollCooldownCount():
				_do_roll_cooldown(delta)
		PlayerStates.Rolling:
			_continue_roll(delta)

func _enter_state(state, delta):
	match state:
		PlayerStates.Rolling:
			_init_roll()

func _exit_state(state, delta):
	match state:
		PlayerStates.Rolling:
			_start_roll_cooldown()  # Start cooldown when exiting the rolling state
		#PlayerStates.Idle:
			#rollLookAmount = lookAmount
		#PlayerStates.Moving:
			#rollLookAmount = atan2(rollDirection.x, rollDirection.y)

func _transition_states(from, to, delta):
	pass
	#match to:
		#PlayerStates.Rolling when inputRollDirection:
			#rollLookAmount = atan2(rollDirection.x, rollDirection.z)
		#PlayerStates.Rolling when !inputRollDirection:
			#rollLookAmount = lookAmount

func _update_states():
	if isActivelyRolling:
		curr_state = PlayerStates.Rolling
	elif doesPlayerWantToRoll() and canPlayerActuallyRoll():
		curr_state = PlayerStates.Rolling
	elif inputMoveDirection != Vector2.ZERO or movePos != Vector3.ZERO:
		curr_state = PlayerStates.Moving
	else:
		curr_state = PlayerStates.Idle

func doesPlayerWantToRoll():
	return inputDoRollButton or inputRollDirection != Vector2.ZERO

func canPlayerActuallyRoll():
	return timerRollCooldown >= rollCooldown  # Ensure player can only roll after cooldown is over

func shouldRollCooldownCount():
	return timerRollCooldown < rollCooldown

func _update_inputs():
	inputMoveDirection = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	inputRollDirection = Input.get_vector("RollLeft", "RollRight", "RollUp", "RollDown")
	inputDoRollButton = Input.is_action_pressed("RollInput")
	
	if !inputMoveDirection.is_zero_approx():
		movePos = Vector3.ZERO
	elif Input.is_action_pressed("MoveClick"):
		var cam = get_viewport().get_camera_3d()
		if not cam: return
		var origin = cam.project_ray_origin(get_viewport().get_mouse_position())
		var normal = cam.project_ray_normal(get_viewport().get_mouse_position())
		
		## replace this with a raycast once navmeshes are added
		var pos = Plane.PLANE_XZ.intersects_ray(origin, normal)
		
		movePos = pos if pos else Vector3.ZERO

func _update_variables(delta):
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	moveDirection = Vector3(inputMoveDirection.x, 0, inputMoveDirection.y).rotated(Vector3.UP, camera.rotation.y).normalized()
	if !moveDirection and movePos:
		var offset = movePos - position
		if Vector2(offset.x, offset.z).length_squared() < pow(moveSpeed*delta, 2):
			movePos = Vector3.ZERO
		else:
			moveDirection = Plane.PLANE_XZ.project(movePos - position).normalized()
	
	rollDirection = Vector3(inputRollDirection.x, 0, inputRollDirection.y).rotated(Vector3.UP, camera.rotation.y).normalized()
	rollDirection = moveDirection if rollDirection.is_zero_approx() else rollDirection

func _move_player():
	if moveDirection != Vector3.ZERO:
		velocity = moveDirection * moveSpeed
		move_and_slide()

func _update_rotation_variables():
	lookDirection = moveDirection
	lookAmount = atan2(lookDirection.x, lookDirection.z)

func _rotate_player(delta: float):
	if curr_state != PlayerStates.Rolling:
		rotation = Vector3(0, lerp_angle(rotation.y, lookAmount, 0.15), 0)

func _init_roll():
	rollLookAmount = atan2(rollDirection.x, rollDirection.z) if inputRollDirection else atan2(lookDirection.x, lookDirection.z)
	rollAnimation.track_set_key_value(0, 0, Vector3(0, rollLookAmount, 0))
	rollAnimation.track_set_key_value(0, 1, Vector3(deg_to_rad(360), rollLookAmount, 0))
	
	rollAnimationPlayer.play("RollAnimation")
	
	isActivelyRolling = true
	timerRoll = 0  # Reset roll time to 0 at the start of the roll
	rollDirection = rollDirection if rollDirection != Vector3.ZERO else lookDirection.normalized()
	rollDirection = rollDirection.normalized()
	velocity = rollDirection * rollSpeed
	
	rollParticles.emitting = true

func _continue_roll(delta):
	# Update roll time and stop roll after duration
	timerRoll += delta
	if timerRoll < rollDuration:
		rollParticles.global_position = Vector3(global_position.x, global_position.y - 0.6, global_position.z)
		rollParticles.global_rotation = Vector3.ZERO
		move_and_slide()
	else:
		isActivelyRolling = false
		curr_state = PlayerStates.Idle  # Transition to Idle when roll ends
		rollParticles.emitting = false
		_start_roll_cooldown()  # Properly call cooldown reset after roll ends

func _start_roll_cooldown():
	# Start the cooldown only when the roll is completed
	timerRollCooldown = 0  # Reset cooldown timer when roll completes

func _do_roll_cooldown(delta):
	# Increase cooldown timer when not rolling
	if timerRollCooldown < rollCooldown:
		timerRollCooldown += delta
		if timerRollCooldown >= rollCooldown:
			timerRollCooldown = rollCooldown  # Ensure cooldown doesn't exceed max value
