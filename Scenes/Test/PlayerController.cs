using Godot;
using System;

public partial class PlayerController : CharacterBody3D
{
    // The stats for the player
    [Export(PropertyHint.Range, "0,25,0.25")] private float playerSpeed, rotationSpeed;
    [Export(PropertyHint.Range, "0,50,0.25")] private float rollSpeed, rollDuration, rollCooldown;

    // Variables used for shtuff
    private bool isRolling, canRoll, isActivelyMoving;
    public bool GetIsRolling
    {
        get { return isRolling; }
        private set { isRolling = value; }
    }
    public bool GetCanRoll
    {
        get { return canRoll; }
        private set { canRoll = value; }
    }
    public bool GetIsActivelyMoving
    {
        get { return isActivelyMoving; }
        private set { isActivelyMoving = value; }
    }

    private Vector3 moveDirection, lookDirection, rollDirection;
    public Vector3 GetMoveDirection
    {
        get { return moveDirection; }
        private set { moveDirection = value; }
    }
    public Vector3 GetLookDirection
    {
        get { return lookDirection; }
        private set { lookDirection = value; }
    }
    public Vector3 GetRollDirection
    {
        get { return rollDirection; }
        private set { rollDirection = value; }
    }

    // The input variables
    private Vector2 inputMoveDirection, inputRollDirection;
    public Vector2 GetInputMoveDirection
    {
        get { return inputMoveDirection; }
        private set { inputMoveDirection = value; }
    }
    public Vector2 GetInputRollDirection
    {
        get { return inputRollDirection; }
        private set { inputRollDirection = value; }
    }
    private bool inputDoRoll;
    public bool GetInputDoRoll
    {
        get { return inputDoRoll; }
        private set { inputDoRoll = value; }
    }

    public override void _Process(double delta)
    {
        UpdateInputs();
    }

    public override void _PhysicsProcess(double delta)
    {
        // Getting the movement direction of the player, then shifting it by 45 degrees so it's accurate to the camera
        moveDirection = Quaternion.FromEuler(new Vector3(0, Mathf.DegToRad(45), 0)) * new Vector3(inputMoveDirection.X, 0, inputMoveDirection.Y);
        // Putting whether or not the player is moving into a bool
        isActivelyMoving = moveDirection != Vector3.Zero;

        if (isActivelyMoving)
        {
            lookDirection = moveDirection;
            float lookAmount = Mathf.RadToDeg(Mathf.Atan2(lookDirection.X, lookDirection.Z));
            RotatePlayer(lookAmount, (float)delta);
        }

        MovePlayer((float)delta);
        if (inputDoRoll && canRoll)
            RollPlayer(delta);
    }

    private void UpdateInputs()
    {
        // The input direction vectors
        inputMoveDirection = Input.GetVector("MoveLeft", "MoveRight", "MoveUp", "MoveDown").Normalized();
        inputRollDirection = Input.GetVector("RollLeft", "RollRight", "RollUp", "RollDown").Normalized();

        // The input booleans
        inputDoRoll = Input.IsActionJustPressed("RollInput");
    }

    private void RotatePlayer(float amount, float delta)
    {
        // Get the current rotation on the Y axis
        float currentRotation = RotationDegrees.Y;

        // Calculate the difference between the current and target rotation
        float deltaRotation = Mathf.Wrap(amount - currentRotation, -180f, 180f);

        // Smoothly interpolate the rotation
        RotationDegrees = new Vector3(0, currentRotation + deltaRotation * rotationSpeed * delta, 0);
    }


    private void RollPlayer(double delta)
    {
        canRoll = false;
        isRolling = true;

        // Setting the velocity's direction to the player's movement direction, making it accurate to the movespeed, and making it frame independent
        Velocity = moveDirection * rollSpeed * ((float)delta * 100);
    }

    private void MovePlayer(float delta)
    {
        // Setting the velocity's direction to the player's movement direction, making it accurate to the movespeed, and making it frame independent
        Velocity = moveDirection * playerSpeed * (delta * 100);
        MoveAndSlide(); // Always needed for movement :>
    }
}
