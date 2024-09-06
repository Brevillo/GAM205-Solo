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
    [SerializeField] private SoundEffect stepSound;
    [SerializeField] private float stepSoundFreqeuncy;
    [SerializeField] private BoxCaster2D wallRight;
    [SerializeField] private BoxCaster2D wallLeft;
    [SerializeField] private float groundedAngleRange;

    [Header("Jumping")]
    [SerializeField] private float jumpHeight;
    [SerializeField] private float jumpGravity;
    [SerializeField] private float fallGravity;
    [SerializeField] private BufferTimer jumpBuffer;
    [SerializeField] private float coyoteTime;
    [SerializeField] private float maxFallSpeed;
    [SerializeField] private BoxCaster2D ground;
    [SerializeField] private BoxCaster2D ceiling;

    [Header("Slamming")]
    [SerializeField] private float minSlamSpeed;

    private bool onGround, onCeiling;
    private int moveDirection, wallDirection;

    private float stepSoundTimer;

    [SerializeField]
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
        onGround = ground.Touching && NormalDistance(ground.Normal, 90) < groundedAngleRange;
        onCeiling = ceiling.Touching && NormalDistance(ceiling.Normal, -90) < groundedAngleRange;

        if (ground.Touching) Debug.DrawRay(ground.Collisions[0].point, ground.Normal * 2, Color.yellow);

        wallDirection = (wallRight.Touching ? 1 : 0) - (wallLeft.Touching ? 1 : 0);

        static float NormalDistance(Vector2 normal, float targetAngle)
            => Mathf.Abs(Mathf.DeltaAngle(Mathf.Atan2(normal.y, normal.x) * Mathf.Rad2Deg, targetAngle));

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
            endJumping = () => Rigidbody.velocity.y <= 0 || !Input.Jump.Pressed || onCeiling,

            toSlamming = () => Input.Slam.Down;

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
                    new(slamming, toSlamming),
                }
            },

            {
                jumping,
                new()
                {
                    new(falling, endJumping),
                    new(slamming, toSlamming),
                }
            },

            {
                slamming,
                new()
                {
                    new(grounded, toGrounded),
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
            bool moving = context.moveDirection != 0 && context.moveDirection != context.wallDirection;
            bool turning = context.moveDirection != Mathf.Sign(XVelocity);

            float accel = context.onGround
                ? moving ? turning ? context.groundTurnAccel : context.groundAccel : context.groundDeccel
                : moving ? turning ? context.airTurnAccel    : context.airAccel    : context.airDeccel;

            float targetSpeed = Mathf.Abs(XVelocity) > context.runSpeed ? XVelocity : context.runSpeed;

            XVelocity = Mathf.MoveTowards(XVelocity, context.moveDirection * targetSpeed, accel * Time.deltaTime);

            if (context.onGround && moving)
            {
                context.stepSoundTimer += Time.deltaTime;

                if (context.stepSoundTimer > context.stepSoundFreqeuncy)
                {
                    context.stepSoundTimer = 0;
                    context.stepSound.Play(context);
                }
            }
            else
            {
                context.stepSoundTimer = Mathf.Infinity;
            }
        }

        protected void Fall(float gravity)
        {
            YVelocity = Mathf.MoveTowards(YVelocity, -context.maxFallSpeed, gravity * Time.deltaTime);
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
            Fall(context.fallGravity);

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
            YVelocity = Mathf.Sqrt(context.jumpHeight * context.jumpGravity * 2f);
        }

        public override void Update()
        {
            Run();
            Fall(context.jumpGravity);

            base.Update();
        }

        public override void Exit()
        {
            YVelocity = 0;

            base.Exit();
        }
    }

    private class Slamming : State
    {
        public Slamming(PlayerMovement context) : base(context) { }

        public override void Enter()
        {
            base.Enter();

            float slamSpeed = Mathf.Max(context.minSlamSpeed, Velocity.magnitude);

            Velocity = new(0, -slamSpeed);
        }

        public override void Update()
        {
            Run();

            base.Update();
        }
    }
}
