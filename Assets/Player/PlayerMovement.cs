using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using OliverBeebe.UnityUtilities.Runtime;

public class PlayerMovement : Player.Component
{
    [SerializeField] private float runSpeed;
    [SerializeField] private float groundAccel;
    [SerializeField] private float groundDeccel;
    [SerializeField] private float groundTurnAccel;
    [SerializeField] private float airAccel;
    [SerializeField] private float airDeccel;
    [SerializeField] private float airTurnAccel;

    [Header("Jumping")]
    [SerializeField] private float jumpHeight;
    [SerializeField] private float gravity;
    [SerializeField] private BufferTimer jumpBuffer;
    [SerializeField] private float coyoteTime;
    [SerializeField] private float maxFallSpeed;
    [SerializeField] private BoxCaster2D ground;
    [SerializeField] private BoxCaster2D ceiling;

    private bool onGround, onCeiling;
    private int moveDirection;

    private StateMachine stateMachine;
    private Grounded grounded;
    private Falling falling;
    private Jumping jumping;
    private Slamming slamming;

    private void Awake()
    {
        InitializeStateMachine();
    }

    private void Update()
    {
        onGround = ground.Touching;
        onCeiling = ceiling.Touching;

        moveDirection = (Input.MoveRight.Pressed ? 1 : 0) - (Input.MoveLeft.Pressed ? 1 : 0);
        jumpBuffer.Buffer(Input.Jump.Down);

        stateMachine.Update(Time.deltaTime);
    }

    private void InitializeStateMachine()
    {
        grounded = new(this);
        falling = new(this);
        jumping = new(this);
        slamming = new(this);

        TransitionDelegate

            toGrounded = () => onGround,

            toFalling = () => !onGround,

            toJumping = () => jumpBuffer && onGround,
            toCoyoteJumping = () => jumpBuffer && stateMachine.previousState == grounded && stateMachine.stateDuration < coyoteTime,
            endJumping = () => Rigidbody.velocity.y <= 0 || !Input.Jump.Pressed || onCeiling;

        stateMachine = new(grounded, new()
        {
            {
                grounded,
                new()
                {
                    new(falling, toFalling),
                    new(jumping, toJumping)
                }
            },

            {
                falling,
                new()
                {
                    new(grounded, toGrounded),
                    new(jumping, toCoyoteJumping),
                }
            },

            {
                jumping,
                new()
                {
                    new(falling, endJumping)
                }
            },

            {
                slamming,
                new()
                {

                }
            },
        });
    }

    private class State : State<PlayerMovement>
    {
        public State(PlayerMovement context) : base(context) { }

        protected Vector2 Velocity
        {
            get => context.Rigidbody.velocity;
            set => context.Rigidbody.velocity = value;
        }

        protected float YVelocity
        {
            get => Velocity.y;
            set
            {
                Vector2 velocity = Velocity;
                velocity.y = value;
                Velocity = velocity;
            }
        }

        protected float XVelocity
        {
            get => Velocity.x;
            set
            {
                Vector2 velocity = Velocity;
                velocity.x = value;
                Velocity = velocity;
            }
        }

        protected void Run()
        {
            bool moving = context.moveDirection != 0;
            bool turning = context.moveDirection != Mathf.Sign(XVelocity);

            float accel = context.onGround
                ? moving ? turning ? context.groundTurnAccel : context.groundAccel : context.groundDeccel
                : moving ? turning ? context.airTurnAccel    : context.airAccel    : context.airDeccel;

            float targetSpeed = Mathf.Abs(XVelocity) > context.runSpeed ? XVelocity : context.runSpeed;

            XVelocity = Mathf.MoveTowards(XVelocity, context.moveDirection * targetSpeed, accel * Time.deltaTime);
        }

        protected void Fall()
        {
            YVelocity = Mathf.MoveTowards(YVelocity, -context.maxFallSpeed, context.gravity * Time.deltaTime);
        }
    }

    private class Grounded : State
    {
        public Grounded(PlayerMovement context) : base(context) { }

        public override void Update()
        {
            Run();

            base.Update();
        }
    }

    private class Falling : State
    {
        public Falling(PlayerMovement context) : base(context) { }

        public override void Update()
        {
            Run();
            Fall();

            base.Update();
        }
    }

    private class Jumping : State
    {
        public Jumping(PlayerMovement context) : base(context) { }

        public override void Enter()
        {
            base.Enter();

            context.jumpBuffer.Reset();
            YVelocity = Mathf.Sqrt(context.jumpHeight * context.gravity * 2f);
        }

        public override void Update()
        {
            Run();
            Fall();

            base.Update();
        }
    }

    private class Slamming : State
    {
        public Slamming(PlayerMovement context) : base(context) { }
    }
}
