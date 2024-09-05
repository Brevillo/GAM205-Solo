using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using OliverBeebe.UnityUtilities.Runtime;

public class BoxCaster2D : MonoBehaviour
{
    public Vector2 direction;
    public Vector2 size;
    public float distance;
    public float angle;
    public LayerMask layerMask;
    public int maxHits = 1;

    public bool Touching => collisionCount > 0;
    public Vector2 Normal => Touching ? collisions[0].normal : Vector2.zero;

    public RaycastHit2D[] Collisions => collisions;
    public int CollisionCount => collisionCount;

    private RaycastHit2D[] collisions;
    private int collisionCount;

    private void Awake()
    {
        if (maxHits != -1)
        {
            collisions = new RaycastHit2D[maxHits];
        }
    }

    private void FixedUpdate()
    {
        if (maxHits == -1)
        {
            collisions = Physics2D.BoxCastAll(
                transform.position,
                size,
                angle,
                direction,
                distance,
                layerMask);

            collisionCount = collisions.Length;
        }
        else
        {
            collisionCount = Physics2D.BoxCastNonAlloc(
                transform.position,
                size,
                angle,
                direction,
                collisions,
                distance,
                layerMask);
        }
    }

    private void OnDrawGizmosSelected()
    {
        var rotation = Quaternion.AngleAxis(angle, Vector3.forward);

        Vector3 start = transform.position;
        Vector3 end = transform.position + (Vector3)direction.normalized * distance;
        Vector2 extent = size / 2f;

        Gizmos.color = Touching ? Color.red : Color.green;

        Gizmos.DrawLineStrip(new(new[] 
        {
            start + rotation * new Vector3(extent.x, -extent.y),
            start + rotation * new Vector3(-extent.x, -extent.y),
            start + rotation * new Vector3(-extent.x, extent.y),
            start + rotation * new Vector3(extent.x, extent.y),
        }), true);

        Gizmos.DrawLineStrip(new(new[]
        {
            end + rotation * new Vector3(extent.x, -extent.y),
            end + rotation * new Vector3(-extent.x, -extent.y),
            end + rotation * new Vector3(-extent.x, extent.y),
            end + rotation * new Vector3(extent.x, extent.y),
        }), true);

        Gizmos.DrawLineList(new(new[]
        {
            start + rotation * new Vector3(extent.x, -extent.y),
            end + rotation * new Vector3(extent.x, -extent.y),

            start + rotation * new Vector3(-extent.x, -extent.y),
            end + rotation * new Vector3(-extent.x, -extent.y),

            start + rotation * new Vector3(-extent.x, extent.y),
            end + rotation * new Vector3(-extent.x, extent.y),

            start + rotation * new Vector3(extent.x, extent.y),
            end + rotation * new Vector3(extent.x, extent.y),
        }));

        float arrowSize = Mathf.Min(extent.x, extent.y) / 2f;

        if (direction != Vector2.zero)
        {
            var arrowRotation = Quaternion.FromToRotation(Vector3.right, direction);

            Gizmos.DrawLineStrip(new(new[]
            {
                start + arrowRotation * new Vector3(-arrowSize, arrowSize),
                start + arrowRotation * new Vector3(arrowSize, 0),
                start + arrowRotation * new Vector3(-arrowSize, -arrowSize),
            }), false);
        }
        else
        {
            Gizmos.color = Color.red;
            Gizmos.DrawLineList(new(new[]
            {
                start - new Vector3(arrowSize, arrowSize),
                start + new Vector3(arrowSize, arrowSize),
                start + new Vector3(-arrowSize, arrowSize),
                start - new Vector3(-arrowSize, arrowSize),
            }));
        }
    }
}
