using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using OliverBeebe.UnityUtilities.Runtime;

public class MainMenu : MonoBehaviour
{
    [SerializeField] private Transform cameraPivot;
    [SerializeField] private new Camera camera;
    [SerializeField] private Transform cameraTarget;
    [SerializeField] private Scene playScene;
    [SerializeField] private float lookAmplitude;

    private void Update()
    {
        Vector2 mousePosition = Input.mousePosition / new Vector2(Screen.width, Screen.height) * 2 - Vector2.one;
        mousePosition.x = Mathf.Clamp(mousePosition.x, -1, 1);
        mousePosition.y = Mathf.Clamp(mousePosition.y, -1, 1);
        cameraTarget.localPosition = mousePosition * lookAmplitude;

        cameraPivot.LookAt(cameraTarget);
    }

    public void Play()
    {
        UnityEngine.SceneManagement.SceneManager.LoadScene(playScene);
    }

    public void Quit()
    {
        Application.Quit();
    }
}
