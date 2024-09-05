using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using OliverBeebe.UnityUtilities.Runtime;

public class CollisionAggregate2D : MonoBehaviour
{
    [Readonly, SerializeField] private bool touching;

    public bool Touching => colliders.Count > 0;
    public List<Collider2D> Colliders => colliders;

    private List<Collider2D> newColliders;
    private List<Collider2D> colliders;

    private void Awake()
    {
        newColliders = new();
        colliders = new();
    }

    private void OnTriggerStay2D(Collider2D collision)
    {
        if (!newColliders.Contains(collision))
        {
            newColliders.Add(collision);
        }
    }

    private void FixedUpdate()
    {
        colliders = newColliders;
        newColliders = new();

        touching = Touching;
    }
}
