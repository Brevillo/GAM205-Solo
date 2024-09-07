using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class Perspective2DCamera : MonoBehaviour
{
    [SerializeField] private new Camera camera;
    [SerializeField] private Vector2 screenSize;
    [SerializeField] private bool drawGizmos;

    private void Update()
    {
        float height = screenSize.y;
        float fov = camera.fieldOfView;
        float distance = height / 2f * Mathf.Tan((90f - fov / 2) * Mathf.Deg2Rad);

        Vector3 position = transform.localPosition;
        position.z = -distance;
        transform.localPosition = position;
    }

    private void OnDrawGizmos()
    {
        if (!drawGizmos) return;

        Gizmos.color = Color.white;
        Gizmos.DrawWireCube(new Vector2(transform.position.x, transform.position.y), screenSize);
    }
}
