using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using OliverBeebe.UnityUtilities.Runtime;

public class Credits : MonoBehaviour
{
    [SerializeField] private float creditsDuration;
    [SerializeField] private RectTransform credits;
    [SerializeField] private GameObject enableOnStart;
    [SerializeField] private SmartCurve fadeout;
    [SerializeField] private CanvasGroup fadeoutCanvas;
    [SerializeField] private Scene mainMenu;
    [SerializeField] private float cameraSpeed;

    private bool started;
    private float creditsPercent;
    private Vector2 startPosition;
    private Vector2 endPosition;

    private void OnTriggerEnter2D(Collider2D collision)
    {
        StartCredits();
    }

    [ContextMenu("Start Credits")]
    public void StartCredits()
    {
        if (started) return;

        started = true;
        startPosition = credits.localPosition;
        endPosition = credits.anchoredPosition + Vector2.up * (credits.rect.height + ((RectTransform)credits.parent).rect.height / 2f);

        enableOnStart.SetActive(true);

        StartCoroutine(Sequence());
    }

    private void Start()
    {
        enableOnStart.SetActive(false);
    }

    private IEnumerator Sequence()
    {
        var camMovement = FindObjectOfType<CameraMovement>();
        var camera = camMovement.transform;
        Destroy(camMovement);

        Vector2 cameraVelocity = Vector2.zero;

        while (creditsPercent != 1)
        {
            creditsPercent = Mathf.MoveTowards(creditsPercent, 1, Time.deltaTime / creditsDuration);

            credits.localPosition = Vector2.Lerp(startPosition, endPosition, creditsPercent);

            camera.position = Vector2.SmoothDamp(camera.position, transform.position, ref cameraVelocity, cameraSpeed);

            yield return null;
        }

        fadeout.Start();
        while (!fadeout.Done)
        {
            fadeoutCanvas.alpha = fadeout.Evaluate();

            yield return null;
        }

        UnityEngine.SceneManagement.SceneManager.LoadScene(mainMenu);
    }
}
