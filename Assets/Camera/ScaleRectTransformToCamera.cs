using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(RectTransform))]
[ExecuteAlways]
public class ScaleRectTransformToCamera : MonoBehaviour
{
    [SerializeField] private float distance;
    [SerializeField] private Camera renderCamera;
    [SerializeField] private bool localSpace;

    private void LateUpdate()
    {
        float height = 2f * distance / Mathf.Tan((90 - renderCamera.fieldOfView / 2f) * Mathf.Deg2Rad);
        var rect = ((RectTransform)transform).rect;
        transform.localScale = Vector3.one * height / rect.height;

        Vector3 position = renderCamera.transform.position + renderCamera.transform.forward * distance;
        Quaternion rotation = renderCamera.transform.rotation;

        if (localSpace)
        {
            transform.SetLocalPositionAndRotation(position, rotation);
        }
        else
        {
            transform.SetPositionAndRotation(position, rotation);
        }
    }
}
