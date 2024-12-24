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

var prevMoveDirection: Vector3 = Vector3.ZERO
var rollLookDirection: Vector3 = Vector3.ZERO
var isActivelyRolling: bool = false

var timerRoll: float = 0
var timerRollCooldown: float = 0

var inputMoveDirection: Vector2 = Vector2.ZERO
var inputRollDirection: Vector2 = Vector2.ZERO
var inputDoRollButton: bool = false

func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	_update_states()
	
	if (curr_state != prev_state):
		_exit_state(prev_state, delta)
		_transition_states(prev_state, curr_state, delta)
		_enter_state(curr_state, delta)
	
	_update_active_state(delta)
	_update_inputs()
	_update_variables()
	
	prev_state = curr_state

func _update_active_state(delta):
	match curr_state:
		PlayerStates.Idle:
			_handle_idle_state(delta)
		PlayerStates.Moving:
			_move_player(delta)
		PlayerStates.Rolling:
			_continue_roll_player(delta)

func _enter_state(state, delta):
	match state:
		PlayerStates.Rolling:
			_init_roll_player(rollDirection, delta)

func _exit_state(state, delta):
	match state:
		PlayerStates.Rolling:
			_reset_roll()

func _transition_states(from, to, delta):
	match from:
		PlayerStates.Rolling:
			if to != PlayerStates.Rolling:
				_reset_roll()

func _update_states():
	if inputDoRollButton and timerRollCooldown == 0:
		# If the roll button is pressed, roll in the look direction
		rollDirection = lookDirection
		curr_state = PlayerStates.Rolling
	elif inputRollDirection != Vector2.ZERO and !isActivelyRolling:  # Roll direction is now prioritized only when not already rolling
		# If the right joystick is moved, roll in the joystick direction
		rollDirection = (Quaternion.from_euler(Vector3(0, 45, 0)) * Vector3(inputRollDirection.x, 0, inputRollDirection.y)).normalized()
		curr_state = PlayerStates.Rolling
	elif isActivelyRolling:
		curr_state = PlayerStates.Rolling
	elif inputMoveDirection != Vector2.ZERO and !inputDoRollButton:
		curr_state = PlayerStates.Moving
	elif inputMoveDirection == Vector2.ZERO and !inputDoRollButton:
		curr_state = PlayerStates.Idle

func _update_inputs():
	inputMoveDirection = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")  # Move direction
	inputRollDirection = Input.get_vector("RollLeft", "RollRight", "RollUp", "RollDown")  # Roll direction
	inputDoRollButton = Input.is_action_just_pressed("RollInput")  # Roll button

func _update_variables():
	moveDirection = Vector3(inputMoveDirection.x, 0, inputMoveDirection.y)
	moveDirection = (Quaternion.from_euler(Vector3(0, 45, 0)) * moveDirection).normalized()

	# Update roll direction only when roll starts, lock it during the roll
	if curr_state == PlayerStates.Rolling and !isActivelyRolling:
		rollDirection = (Quaternion.from_euler(Vector3(0, 45, 0)) * Vector3(inputRollDirection.x, 0, inputRollDirection.y)).normalized()

func _init_roll_player(direction: Vector3, delta: float):
	isActivelyRolling = true
	timerRoll = 0
	rollLookDirection = lookDirection  # Set roll direction to current look direction
	_do_roll_timer(delta)

func _do_roll_timer(delta):
	if (isActivelyRolling):
		timerRoll += delta
		if (timerRoll >= rollDuration):
			timerRoll = 0
			isActivelyRolling = false
			timerRollCooldown = 0  # Reset cooldown after roll finishes

func _do_roll_cooldown(delta):
	if (timerRollCooldown < rollCooldown):
		timerRollCooldown += delta
	else:
		timerRollCooldown = rollCooldown  # Ensure it doesn't exceed cooldown

func _continue_roll_player(delta):
	if (!isActivelyRolling):
		return
	
	_do_roll_timer(delta)
	velocity = rollDirection * rollSpeed  # Roll in the roll direction, not look direction
	move_and_slide()

func _move_player(delta):
	lookDirection = moveDirection
	velocity = moveDirection * moveSpeed
	move_and_slide()

func _handle_idle_state(delta):
	if (timerRollCooldown > 0):
		_do_roll_cooldown(delta)

# The reset function to properly exit the rolling state
func _reset_roll():
	isActivelyRolling = false
	rollLookDirection = Vector3.ZERO
	timerRoll = 0
	timerRollCooldown = 0  # Optionally reset the cooldown here too
