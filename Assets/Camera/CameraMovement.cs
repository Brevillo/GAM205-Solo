using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovement : MonoBehaviour
{
    [SerializeField] private Transform target;
    [SerializeField] private int pixelsPerUnit;
    [SerializeField] private float dampSpeed;

    private Vector2 position;
    private Vector2 dampVelocity;

    private void LateUpdate()
    {
        Vector2 targetPosition =
            new(target.position.x, position.y);
            //new(Mathf.Max(position.x, target.position.x), position.y);

        position = Vector2.SmoothDamp(position, targetPosition, ref dampVelocity, dampSpeed);

        transform.position = SnapToPixels(position);
    }

    private Vector2 SnapToPixels(Vector2 position) => new(
        Mathf.Round(position.x * pixelsPerUnit) / pixelsPerUnit,
        Mathf.Round(position.y * pixelsPerUnit) / pixelsPerUnit);
}
