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

@export_group("Misc. stats")
@export_range(0, 25, 0.1) var moveSpeed: float
@export_range(0, 50, 0.25) var rotateSpeed: float
@export_group("Roll Stats")
@export_range(0, 100, 0.5) var rollSpeed: float
@export_range(0, 10, 0.1) var rollDuration: float
@export_range(0, 10, 0.1) var rollCooldown: float

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

func _physics_process(delta):
	_update_states()
	_update_variables()
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

func _transition_states(from, to, delta):
	pass

func _update_states():
	if isActivelyRolling:
		curr_state = PlayerStates.Rolling
	elif doesPlayerWantToRoll() and canPlayerActuallyRoll():
		curr_state = PlayerStates.Rolling
	elif inputMoveDirection != Vector2.ZERO:
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

func _update_variables():
	moveDirection = Quaternion.from_euler(Vector3(0, 45, 0)) * Vector3(inputMoveDirection.x, 0, inputMoveDirection.y).normalized()
	#if curr_state != PlayerStates.Rolling:
	rollDirection = Quaternion.from_euler(Vector3(0, 45, 0)) * Vector3(inputRollDirection.x, 0, inputRollDirection.y).normalized()
	rollDirection = moveDirection if !rollDirection else rollDirection

func _move_player():
	if inputMoveDirection != Vector2.ZERO:
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

func _continue_roll(delta):
	# Update roll time and stop roll after duration
	timerRoll += delta
	if timerRoll < rollDuration:
		move_and_slide()
	else:
		isActivelyRolling = false
		curr_state = PlayerStates.Idle  # Transition to Idle when roll ends
		_start_roll_cooldown()  # Properly call cooldown reset after roll ends

func _start_roll_cooldown():
	timerRollCooldown = 0  # Reset cooldown timer to 'start' it

func _do_roll_cooldown(delta):
	# Increase cooldown timer when not rolling
	if timerRollCooldown < rollCooldown:
		timerRollCooldown += delta
		if timerRollCooldown >= rollCooldown:
			timerRollCooldown = rollCooldown  # Ensure cooldown doesn't exceed max value
