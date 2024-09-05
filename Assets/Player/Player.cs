using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    [SerializeField] private new Rigidbody2D rigidbody;
    [SerializeField] private GameplayInput input;

    public class Component : MonoBehaviour
    {
        [SerializeField] private Player player;

        protected Player Player => player;
        protected Rigidbody2D Rigidbody => player.rigidbody;
        protected GameplayInput Input => player.input;
    }
}
