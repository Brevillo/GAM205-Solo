using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using OliverBeebe.UnityUtilities.Runtime.Input;

[CreateAssetMenu]
public class GameplayInput : InputService
{
    public InputAction MoveRight;
    public InputAction MoveLeft;
    public InputAction Jump;
    public InputAction Slam;
    public InputAction Attack;
    public InputAction DebugCanvas;
}
