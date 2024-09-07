using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using OliverBeebe.UnityUtilities.Runtime;

public class PauseMenu : Player.Component
{
    [SerializeField] private Scene mainMenu;
    [SerializeField] private GameObject content;

    private bool paused;

    public bool Paused => paused;

    private void Start()
    {
        Pause(false);
    }

    private void Update()
    {
        if (Input.Pause.Down)
        {
            Pause(!paused);
        }
    }

    private void Pause(bool paused)
    {
        this.paused = paused;

        if (paused)
        {
            content.SetActive(true);
        }
        else
        {
            content.SetActive(false);
        }
    }

    public void Resume()
    {
        Pause(false);
    }

    public void ReturnToMain()
    {
        Pause(false);
        UnityEngine.SceneManagement.SceneManager.LoadScene(mainMenu);
    }
}
