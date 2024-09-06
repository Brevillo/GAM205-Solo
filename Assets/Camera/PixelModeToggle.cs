using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PixelModeToggle : MonoBehaviour
{
    [SerializeField] private Camera mainCamera;
    [SerializeField] private RenderTexture renderTexture;
    [SerializeField] private GameObject renderCamera;

    private bool pixeled;

    private void Start()
    {
        pixeled = true;
    }

    public void TogglePixelMode() => TogglePixelMode(!pixeled);

    public void TogglePixelMode(bool pixeled)
    {
        this.pixeled = pixeled;

        if (pixeled)
        {
            mainCamera.targetTexture = renderTexture;
            renderCamera.SetActive(true);
        }
        else
        {
            mainCamera.targetTexture = null;
            renderCamera.SetActive(false);
        }
    }
}
