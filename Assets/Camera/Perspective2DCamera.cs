using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class Perspective2DCamera : MonoBehaviour
{
    [SerializeField] private new Camera camera;
    [SerializeField] private Vector2 screenSize;

    private void Update()
    {
        float height = screenSize.y;
        float fov = camera.fieldOfView;
        float distance = height / 2f * Mathf.Tan((90f - fov / 2) * Mathf.Deg2Rad);

        Vector3 position = transform.position;
        position.z = -distance;
        transform.position = position;
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.white;
        Gizmos.DrawWireCube(new Vector2(transform.position.x, transform.position.y), screenSize);
    }
}
