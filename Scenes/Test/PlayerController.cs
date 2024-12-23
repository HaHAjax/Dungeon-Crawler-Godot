using Godot;
using System;

public partial class PlayerController : CharacterBody3D
{
    // The stats for the player
    [Export(PropertyHint.Range, "0,25,0.25")] private float playerSpeed, rotationSpeed;
    [Export(PropertyHint.Range, "0,50,0.1")] private float rollSpeed, rollDuration, rollCooldown;

    // Getting a reference to other node(s)
    private AnimationPlayer rollAnimationPlayer;

    // The bools for shtuff
    private bool isRolling = false;
    private bool canRoll = true;
    private bool isActivelyMoving = false;

    // The directions for shtuff
    private Vector3 moveDirection = Vector3.Zero;
    private Vector3 lookDirection = Vector3.Zero;
    private Vector3 rollDirection = Vector3.Zero;

    // The input directions for shtuff
    private Vector2 inputMoveDirection = Vector2.Zero;
    private Vector2 inputRollDirection = Vector2.Zero;
    private bool inputDoRollDirection = false;
    private bool inputDoRollButton = false;

    // Timers for rolling
    private float rollTimer = 0f;
    private float rollCooldownTimer = 0f;

    // For the debug UI
    public bool IsRolling => isRolling;
    public bool CanRoll => canRoll;
    public bool IsActivelyMoving => isActivelyMoving;
    public Vector3 MoveDirection => moveDirection;
    public Vector3 LookDirection => lookDirection;
    public Vector3 RollDirection => rollDirection;
    public Vector2 InputMoveDirection => inputMoveDirection;
    public Vector2 InputRollDirection => inputRollDirection;
    public bool InputDoRoll => inputDoRollButton;

    public override void _Ready()
    {
        rollAnimationPlayer = GetNode<AnimationPlayer>("RollAnimation");
    }

    public override void _Process(double delta)
    {
        // Update timers
        if (isRolling)
        {
            rollTimer += (float)delta;
            if (rollTimer >= rollDuration) // End the roll after the duration
            {
                isRolling = false;
                rollTimer = 0f; // Reset the roll timer
                rollCooldownTimer = 0f; // Reset the cooldown timer
                canRoll = false; // Start the cooldown immediately after rolling
            }
        }
        else if (!canRoll)
        {
            rollCooldownTimer += (float)delta;
            if (rollCooldownTimer >= rollCooldown) // Allow another roll after cooldown
            {
                canRoll = true; // Enable roll after cooldown
                rollCooldownTimer = 0f; // Reset cooldown timer
            }
        }
    }

    public override void _PhysicsProcess(double delta)
    {
        UpdateInputs();

        // Movement direction based on input
        moveDirection = (Quaternion.FromEuler(new Vector3(0, 45f, 0)) * new Vector3(inputMoveDirection.X, 0, inputMoveDirection.Y)).Normalized();
        isActivelyMoving = moveDirection != Vector3.Zero;

        // Only update roll direction if not rolling yet
        if (!isRolling)
        {
            rollDirection = (Quaternion.FromEuler(new Vector3(0, 45f, 0)) * new Vector3(inputRollDirection.X, 0, inputRollDirection.Y)).Normalized();
            inputDoRollDirection = inputRollDirection != Vector2.Zero;
        }

        // If the player presses the roll button and can roll, start the roll
        if (inputDoRollButton && canRoll && !isRolling)
        {
            RollPlayer(true); // Roll with the direction the player is facing
        }
        // If the player provides a roll direction and can roll, start the roll
        else if (inputDoRollDirection && canRoll && !isRolling)
        {
            RollPlayer(false); // Roll in the custom direction the player is inputting
        }

        if ((inputDoRollButton && canRoll && !isRolling) || (inputDoRollDirection && canRoll && !isRolling))
        {
            PlayRollAnimation(); // Play the roll animation
        }

        // Apply regular movement only if not rolling
        if (!isRolling && isActivelyMoving)
        {
            lookDirection = moveDirection;
            float lookAmount = Mathf.RadToDeg(Mathf.Atan2(lookDirection.X, lookDirection.Z));

            RotatePlayer(lookAmount, (float)delta);
            MovePlayer((float)delta);
        }
        // Apply rolling movement while rolling
        else if (isRolling)
        {
            // Keep moving in the roll direction during the entire roll duration
            Velocity = rollDirection * rollSpeed; // Set velocity to the roll direction
            MoveAndSlide(); // Perform physics movement
        }
        else if (!isRolling || (!isRolling && isActivelyMoving))
        {
            StopRollAnimation(); // Stop the roll animation
        }
    }

    private void UpdateInputs()
    {
        inputMoveDirection = Input.GetVector("MoveLeft", "MoveRight", "MoveUp", "MoveDown").Normalized();
        inputRollDirection = Input.GetVector("RollLeft", "RollRight", "RollUp", "RollDown").Normalized();
        inputDoRollButton = Input.IsActionJustPressed("RollInput");
    }

    private void RotatePlayer(float amount, float delta)
    {
        // This keeps the player's facing direction in sync with the movement input.
        if (!isRolling)
        {
            // Adjust for the isometric camera rotation by adding 45 degrees
            Rotation = new Vector3(0, Mathf.LerpAngle(Rotation.Y, Mathf.DegToRad(amount), rotationSpeed * delta), 0);
        }
    }

    private void RollPlayer(bool isFromButton)
    {
        if (!canRoll) return; // Prevent rolling if cooldown hasn't finished yet

        isRolling = true; // Start the roll
        rollTimer = 0f; // Reset roll timer
        rollCooldownTimer = 0f; // Reset cooldown timer immediately to avoid overlapping cooldowns

        // Do the actual roll logic
        if (isFromButton)
        {
            rollDirection = lookDirection; // Roll in the direction the player is facing
        }
        else
        {
            rollDirection = (Quaternion.FromEuler(new Vector3(0, 45f, 0)) * new Vector3(inputRollDirection.X, 0, inputRollDirection.Y)).Normalized(); // Roll in the direction input by the player
        }

        canRoll = false; // Start cooldown immediately after rolling
    }

    private void MovePlayer(float delta)
    {
        Velocity = moveDirection * playerSpeed;
        MoveAndSlide(); // Apply the movement based on the current direction and speed
    }

    private void PlayRollAnimation()
    {
        // Ensure the AnimationPlayer and the roll animation are valid
        if (rollAnimationPlayer == null || !rollAnimationPlayer.HasAnimation("RollAnimation"))
        {
            GD.PrintErr("AnimationPlayer or 'RollAnimation' is not set.");
            return;
        }

        rollAnimationPlayer.Play("RollAnimation");
    }

    private void StopRollAnimation()
    {
        if (rollAnimationPlayer.IsPlaying() && !isRolling)
        {
            rollAnimationPlayer.Stop();
        }
    }
}
