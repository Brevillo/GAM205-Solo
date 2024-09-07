using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class CameraMovement : MonoBehaviour
{
    [SerializeField] private Transform target;
    [SerializeField] private int pixelsPerUnit;
    [SerializeField] private float dampSpeed;
    [SerializeField] private float cameraTrackDistance;

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
        => transform.position = CameraTrack.Constrain(SnapToPixels(position), cameraTrackDistance);

    private Vector2 SnapToPixels(Vector2 position) => new(
        Mathf.Round(position.x * pixelsPerUnit) / pixelsPerUnit,
        Mathf.Round(position.y * pixelsPerUnit) / pixelsPerUnit);
}
