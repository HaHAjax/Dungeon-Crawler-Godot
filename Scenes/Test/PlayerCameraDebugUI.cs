using Godot;
using System;

public partial class PlayerCameraDebugUI : CanvasLayer
{
    private PlayerController playerControllerScript;

    public override void _Ready()
    {
        // Adjust the node path to match the actual path in the scene tree
        //var playerNode = GetNode<CharacterBody3D>("../Player");
        //if (playerNode == null)
        //{
        //    GD.PrintErr("Player node not found!");
        //    return;
        //}

        //playerController = playerNode as PlayerController;
        //if (playerController == null)
        //{
        //    GD.PrintErr("PlayerController script not found on Player node!");
        //}
        //else
        //{
        //    GD.Print("PlayerController script successfully referenced.");
        //}

        playerControllerScript = GetNode<PlayerController>("Player");
    }

    public override void _Process(double delta)
    {
        if (playerControllerScript != null)
        {
            GetNode<Label>("DebugUI/DebugVariablesLeft/IsPlayerRolling/IsRollDebugValue").Text = playerControllerScript.GetIsRolling.ToString();
            GetNode<Label>("DebugUI/DebugVariablesLeft/CanPlayerRoll/CanRollDebugValue").Text = playerControllerScript.GetCanRoll.ToString();
            GetNode<Label>("DebugUI/DebugVariablesLeft/IsActivelyMoving/IsMoveDebugValue").Text = playerControllerScript.GetIsActivelyMoving.ToString();
            GetNode<Label>("DebugUI/DebugVariablesLeft/MoveDirection/MoveDirDebugValue").Text = playerControllerScript.GetMoveDirection.ToString();
            GetNode<Label>("DebugUI/DebugVariablesLeft/LookDirection/LookDirDebugValue").Text = playerControllerScript.GetLookDirection.ToString();
            GetNode<Label>("DebugUI/DebugVariablesLeft/RollDirection/RollDirDebugValue").Text = playerControllerScript.GetRollDirection.ToString();
            GetNode<Label>("DebugUI/DebugVariablesRight/InputDoRoll/IDoRollDebugValue").Text = playerControllerScript.GetInputDoRoll.ToString();
            GetNode<Label>("DebugUI/DebugVariablesRight/InputMoveDirection/IMoveDirDebugValue").Text = playerControllerScript.GetInputMoveDirection.ToString();
            GetNode<Label>("DebugUI/DebugVariablesRight/InputRollDirection/IRollDirDebugValue").Text = playerControllerScript.GetInputRollDirection.ToString();
            //GD.Print(playerControllerScript);
        }
    }
}
