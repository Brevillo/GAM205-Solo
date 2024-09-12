using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class RenderToAspect : MonoBehaviour
{
    [SerializeField] private Vector2 aspect;
    [SerializeField] private Camera renderCamera;

    private Vector2Int screenSize;

    private void LateUpdate()
    {
        Vector2Int size = new(Screen.width, Screen.height);

        if (size != screenSize)
        {
            screenSize = size;

            float ratio = aspect.x / aspect.y;

            Vector2 adjustedSize = new(
                Mathf.Min(screenSize.x, screenSize.y * ratio),
                Mathf.Min(screenSize.y, screenSize.x / ratio));

            Vector2 normalized = adjustedSize / screenSize;

            renderCamera.rect = new((Vector2.one - normalized) / 2f, normalized);
        }
    }
}
