using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using OliverBeebe.UnityUtilities.Runtime;
using UnityEngine.UI;

public class MainMenu : MonoBehaviour
{
    private static bool splashPlayed;

    [SerializeField] private Transform cameraPivot;
    [SerializeField] private new Camera camera;
    [SerializeField] private Transform cameraTarget;
    [SerializeField] private Scene playScene;
    [SerializeField] private float lookAmplitude;

    [Header("Splash Screen")]
    [SerializeField] private SmartCurve splashFadein;
    [SerializeField] private Color logoStartColor;
    [SerializeField] private Color logoBaseColor;
    [SerializeField] private float splashColorDelay;
    [SerializeField] private SmartCurve splashColorFade;
    [SerializeField] private Image logo;
    [SerializeField] private Image background;
    [SerializeField] private Color logoEndColor;
    [SerializeField] private Color backgroundEndColor;
    [SerializeField] private float coloredLogoDelay;
    [SerializeField] private SmartCurve splashFadeout;
    [SerializeField] private SmartCurve splashZoomout;
    [SerializeField] private GraphicRaycaster mainMenuRaycaster;
    [SerializeField] private Transform mask;
    [SerializeField] private Transform scaler;
    [SerializeField] private Transform splashZoomStart;
    [SerializeField] private Transform splashZoomEnd;
    [SerializeField] private GameObject splashScreen;
    [SerializeField] private AudioSource windAudio;
    [SerializeField] private AudioSource bellsAudio;
    [SerializeField] private SmartCurve splashAudioFadein;

    private Coroutine splashRoutine;

    private Quaternion LookRotation => Quaternion.LookRotation(cameraTarget.position - splashZoomEnd.position);

    private void Start()
    {
        if (!splashPlayed)
        {
            splashRoutine = StartCoroutine(SplashScreen());
        }
        else
        {
            splashScreen.SetActive(false);
        }
    }

    private IEnumerator SplashScreen()
    {
        splashPlayed = true;

        float windVolume = windAudio.volume;
        float bellsVolume = bellsAudio.volume;
        windAudio.volume = 0;
        bellsAudio.volume = 0;

        splashScreen.SetActive(true);
        cameraPivot.position = splashZoomStart.position;
        mainMenuRaycaster.enabled = false;

        splashFadein.Start();
        while (!splashFadein.Done)
        {
            logo.color = Color.Lerp(logoStartColor, logoBaseColor, splashFadein.Evaluate());
            yield return null;
        }

        yield return new WaitForSeconds(splashColorDelay);

        var backgroundStartColor = background.color;

        splashColorFade.Start();
        while (!splashColorFade.Done)
        {
            float percent = splashColorFade.Evaluate();
            logo.color = Color.Lerp(logoBaseColor, logoEndColor, percent);
            background.color = Color.Lerp(backgroundStartColor, backgroundEndColor, percent);
            yield return null;
        }

        yield return new WaitForSeconds(coloredLogoDelay);

        splashFadeout.Start();
        splashZoomout.Start();
        splashAudioFadein.Start();
        while (!splashZoomout.Done)
        {
            float maskPercent = Mathf.Lerp(0.0001f, 1f, splashFadeout.Evaluate());
            mask.localScale = Vector3.one * maskPercent;
            scaler.localScale = Vector3.one / maskPercent;

            float zoomPercent = splashZoomout.Evaluate();
            cameraPivot.SetPositionAndRotation(
                Vector3.Lerp(splashZoomStart.position, splashZoomEnd.position, zoomPercent),
                Quaternion.Slerp(Quaternion.identity, LookRotation, zoomPercent));

            float audioPercent = splashAudioFadein.Evaluate();
            windAudio.volume = windVolume * audioPercent;
            bellsAudio.volume = bellsVolume * audioPercent;

            yield return null;
        }

        splashScreen.SetActive(false);
        mainMenuRaycaster.enabled = true;

        splashRoutine = null;
    }

    private void Update()
    {
        Vector2 mousePosition = Input.mousePosition / new Vector2(Screen.width, Screen.height) * 2 - Vector2.one;
        mousePosition.x = Mathf.Clamp(mousePosition.x, -1, 1);
        mousePosition.y = Mathf.Clamp(mousePosition.y, -1, 1);
        cameraTarget.localPosition = mousePosition * lookAmplitude;

        if (splashRoutine == null)
        {
            cameraPivot.rotation = LookRotation;
        }
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
