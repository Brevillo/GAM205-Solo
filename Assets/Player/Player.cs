using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    [SerializeField] private new Rigidbody2D rigidbody;
    [SerializeField] private GameplayInput input;
    [SerializeField] private PlayerMovement movement;
    [SerializeField] private CameraMovement cameraMovement;
    [SerializeField] private new Collider2D collider;

    private Checkpoint checkpoint;

    public bool RegisterCheckpoint(Checkpoint checkpoint, out Checkpoint oldCheckpoint)
    {
        oldCheckpoint = this.checkpoint;

        if (oldCheckpoint == checkpoint) return false;

        this.checkpoint = checkpoint;

        return true;
    }

    public class Component : MonoBehaviour
    {
        [SerializeField] private Player player;

        protected Player Player => player;
        protected Rigidbody2D Rigidbody => player.rigidbody;
        protected GameplayInput Input => player.input;
        protected PlayerMovement Movement => player.movement;
        protected CameraMovement CameraMovement => player.cameraMovement;
        protected Collider2D Collider => player.collider;

        protected Checkpoint Checkpoint => player.checkpoint;
    }
}
