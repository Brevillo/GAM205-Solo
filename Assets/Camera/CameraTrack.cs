using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

[ExecuteAlways]
public class CameraTrack : MonoBehaviour
{
    [SerializeField] private bool alwaysDrawGizmos;
    [SerializeField] private Color gizmoColor;

    private static readonly Vector2 cameraExtents = new Vector2(84, 36) / 2f;
    private static readonly Vector2[] cameraBoxCorners = new Vector2[]
    {
        new( cameraExtents.x,  cameraExtents.y),
        new( cameraExtents.x, -cameraExtents.y),
        new(-cameraExtents.x, -cameraExtents.y),
        new(-cameraExtents.x,  cameraExtents.y),
    };

    private Transform[] points;
    private Transform[] Points => points ?? GetPoints();

    private Transform[] GetPoints() => points = transform.Cast<Transform>().ToArray();

    private static List<CameraTrack> cameraTracks;

    public static Vector2 Constrain(Vector2 position, float trackDistance)
        => cameraTracks.Count > 0 ? cameraTracks[0].ConstrainInternal(position, trackDistance) : position;

    private Vector2 ConstrainInternal(Vector2 position, float trackDistance)
    {
        if (Points.Length < 2) return position;

        int closestIndex = 0;
        float distance = Mathf.Infinity;

        for (int i = 0; i < Points.Length - 1; i++)
        {
            float newDistance = position.DistToLine(Points[i].position, Points[i + 1].position).sqrMagnitude;

            if (newDistance < distance)
            {
                distance = newDistance;
                closestIndex = i;
            }
        }

        return position.ClampToLineWithinDistance(Points[closestIndex].position, Points[closestIndex + 1].position, trackDistance);
    }

    private void OnEnable()
    {
        cameraTracks ??= new();
        cameraTracks.Add(this);
    }

    private void OnDisable()
    {
        cameraTracks ??= new();
        cameraTracks.Remove(this);
    }

    private void OnDrawGizmos()
    {
        if (alwaysDrawGizmos) DrawGizmos();
    }

    private void OnDrawGizmosSelected()
    {
        if (!alwaysDrawGizmos) DrawGizmos();
    }

    private void DrawGizmos()
    {
        GetPoints();

        Gizmos.color = gizmoColor;

        Gizmos.DrawLineStrip(Points.Select(point => point.position).ToArray(), false);

        foreach (var point in Points)
        {
            Vector2 center = point.position;

            Gizmos.DrawLineStrip(new Vector3[]
            {
                center + cameraBoxCorners[0],
                center + cameraBoxCorners[1],
                center + cameraBoxCorners[2],
                center + cameraBoxCorners[3],
            }, true);
        }
    }
}
