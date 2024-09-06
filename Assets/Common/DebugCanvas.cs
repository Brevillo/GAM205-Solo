using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

#pragma warning disable IDE0051 // Remove unused private members

public class DebugCanvas : DebugCanvasBase
{
    private void ReloadScene() => SceneManager.LoadScene(SceneManager.GetActiveScene().name);

    private void HalveTimeScale() => Time.timeScale *= 0.5f;
    private void DoubleTimeScale() => Time.timeScale *= 2f;
    private void ResetTimeScale() => Time.timeScale = 1f;

    private void TogglePixelCamera() => FindObjectOfType<PixelModeToggle>().TogglePixelMode();

    private void PlayerDie() => FindObjectOfType<PlayerHealth>().Die();
}
