extends CanvasLayer

var playerControllerScript: CharacterBody3D

var labelPaths: Array[String] = [
	"DebugVariablesLeft/currentState/CurrStateDebugValue",
	"DebugVariablesLeft/IsPlayerRolling/CanRollDebugValue",
	"DebugVariablesLeft/LookAmount/LookAmountDebugValue",
	"DebugVariablesLeft/RollLookAmount/RollLookAmDebugValue",
	"DebugVariablesLeft/MoveDirection/MoveDirDebugValue",
	"DebugVariablesLeft/LookDirection/LookDirDebugValue",
	"DebugVariablesLeft/RollDirection/RollDirDebugValue",
	"DebugVariablesLeft/InputDoRoll/IDoRollDebugValue",
	"DebugVariablesLeft/InputMoveDirection/IMoveDirDebugValue",
	"DebugVariablesLeft/InputRollDirection/IRollDirDebugValue",
	"DebugVariablesLeft/RollTimer/RollTimeDebugValue",
	"DebugVariablesLeft/RollCooldown/RollCoolDebugValue"
]

var variableNames: Array[String] = [
	"curr_state",
	"isActivelyRolling",
	"lookAmount",
	"rollLookAmount",
	"moveDirection",
	"lookDirection",
	"rollDirection",
	"inputDoRollButton",
	"inputMoveDirection",
	"inputRollDirection",
	"timerRoll",
	"timerRollCooldown"
]

func _ready():
	playerControllerScript = $"../Player"

func _physics_process(delta):
	for i in range(labelPaths.size()):
		var labelPath = labelPaths[i]
		var label: Label = get_node(labelPath)
		var varName = variableNames[i]
		
		# Using reflection to get the value of the variable from playerControllerScript
		var varValue = playerControllerScript.get(varName)
		
		# Setting the label's text to the variable's value
		label.text = str(varValue)
