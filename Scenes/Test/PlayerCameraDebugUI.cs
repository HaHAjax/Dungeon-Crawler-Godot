using Godot;
using System;

public partial class PlayerCameraDebugUI : CanvasLayer
{
    private PlayerController playerControllerScript;

    public override void _Ready()
    {
        playerControllerScript = GetNode<CharacterBody3D>("/root/Player-Camera/Player") as PlayerController;
    }

    public override void _Process(double delta)
    {
        if (playerControllerScript != null)
        {
            GetNode<Label>("DebugVariablesLeft/IsPlayerRolling/IsRollDebugValue").Text = playerControllerScript.IsRolling.ToString();
            GetNode<Label>("DebugVariablesLeft/CanPlayerRoll/CanRollDebugValue").Text = playerControllerScript.CanRoll.ToString();
            GetNode<Label>("DebugVariablesLeft/IsActivelyMoving/IsMoveDebugValue").Text = playerControllerScript.IsActivelyMoving.ToString();
            GetNode<Label>("DebugVariablesLeft/MoveDirection/MoveDirDebugValue").Text = playerControllerScript.MoveDirection.ToString();
            GetNode<Label>("DebugVariablesLeft/LookDirection/LookDirDebugValue").Text = playerControllerScript.LookDirection.ToString();
            GetNode<Label>("DebugVariablesLeft/RollDirection/RollDirDebugValue").Text = playerControllerScript.RollDirection.ToString();
            GetNode<Label>("DebugVariablesLeft/InputDoRoll/IDoRollDebugValue").Text = playerControllerScript.InputDoRoll.ToString();
            GetNode<Label>("DebugVariablesLeft/InputMoveDirection/IMoveDirDebugValue").Text = playerControllerScript.InputMoveDirection.ToString();
            GetNode<Label>("DebugVariablesLeft/InputRollDirection/IRollDirDebugValue").Text = playerControllerScript.InputRollDirection.ToString();
        }
    }
}
