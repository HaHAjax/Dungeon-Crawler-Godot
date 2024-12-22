using Godot;
using System;

public partial class PlayerController : CharacterBody3D
{
    [Export(PropertyHint.Range, "0,50,0.25")] private float playerSpeed;

    // The input variables
    private Vector2 inputDirection;

    public override void _Process(double delta)
    {
        UpdateInputs();

        MovePlayer();
    }

    private void UpdateInputs()
    {
        inputDirection = Input.GetVector("MoveLeft", "MoveRight", "MoveUp", "MoveDown").Normalized();
    }

    private void MovePlayer()
    {
        var moveDirection = new Vector3(inputDirection.X, 0, inputDirection.Y);
        moveDirection = Quaternion.FromEuler(new Vector3(0, Mathf.DegToRad(45), 0)) * moveDirection;
        Velocity = moveDirection * playerSpeed;
        MoveAndSlide();
    }
}
