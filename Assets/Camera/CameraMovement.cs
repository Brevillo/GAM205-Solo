using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

[ExecuteAlways]
public class CameraMovement : MonoBehaviour
{
    [SerializeField] private Transform target;
    [SerializeField] private int pixelsPerUnit;
    [SerializeField] private float dampSpeed;
    [SerializeField] private float cameraTrackDistance;

    [Header("Elevation Smoothing")]
    [SerializeField] private float averagingDistance;
    [SerializeField] private float averagingPointDistance;
    [SerializeField] private LayerMask groundMask;
    [SerializeField] private float maxCastDistance;
    [SerializeField] private AnimationCurve weightingCurve;
    [SerializeField] private float castHeight;
    [SerializeField] private float groundCameraOffset;

    private Vector2 position;
    private Vector2 dampVelocity;

    public void SnapToTarget()
    {
        position = target.position;
        CalculatePosition();
    }

    private void Start()
    {
        if (Application.IsPlaying(this))
        {
            transform.parent = null;
        }
    }

    private void LateUpdate()
    {
        if (Application.IsPlaying(this))
        {
            UpdatePosition();
            CalculatePosition();
        }
        else
        {
            SnapToTarget();
        }
    }

    private void UpdatePosition()
        => position = Vector2.SmoothDamp(position, target.position, ref dampVelocity, dampSpeed);

    private void CalculatePosition()
        //=> transform.position = CameraTrack.Constrain(SnapToPixels(position), cameraTrackDistance);
        => transform.position = SnapToPixels(AveragePosition(position));

    private Vector2 AveragePosition(Vector2 center)
    {
        int count = Mathf.RoundToInt(averagingDistance / averagingPointDistance);
        Vector2 start = center + new Vector2(averagingDistance / -2f, castHeight);
        Vector2 end = start + Vector2.right * averagingDistance;

        var hits = Enumerable
            .Range(0, count)
            .Select(i => Physics2D.Raycast(Vector2.Lerp(start, end, (float)i / count), Vector2.down, maxCastDistance, groundMask))
            .Where(hit => hit)
            .ToArray();

        if (hits.Length == 0)
        {
            return center + Vector2.up * groundCameraOffset;
        }

        float totalWeight = 0;
        Vector2 average = Vector2.zero;
        for (int i = 0; i < hits.Length; i++)
        {
            float percent = weightingCurve.Evaluate(0.5f - Mathf.Abs((float)i / hits.Length - 0.5f));
            totalWeight += percent;
            average += percent * hits[i].point;
        }

        return average / totalWeight + Vector2.up * groundCameraOffset;;
    }

    private Vector2 SnapToPixels(Vector2 position) => new(
        Mathf.Round(position.x * pixelsPerUnit) / pixelsPerUnit,
        Mathf.Round(position.y * pixelsPerUnit) / pixelsPerUnit);
}
