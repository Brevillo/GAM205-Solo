using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using OliverBeebe.UnityUtilities.Runtime;
using OliverBeebe.UnityUtilities.Runtime.Settings;

public class IntroManager : MonoBehaviour
{
    [SerializeField] private Typewriter typewriter;
    [SerializeField] private Renderer wind;
    [SerializeField] private AudioSource windAudio;
    [SerializeField] private float maxWindVolume;
    [SerializeField] private SmartCurve windFadeIn;
    [SerializeField] private SmartCurve windFadeOut;
    [SerializeField] private SmartCurve fastWindFadeIn;
    [SerializeField] private SmartCurve fastWindFadeOut;
    [SerializeField] private SpriteRenderer blackout;
    [SerializeField] private Scene loadScene;
    [SerializeField] private GameObject skipButton;
    [SerializeField] private BoolSetting watchedIntro;

    private static readonly int windColorEdge = Shader.PropertyToID("_Color_Edge");

    private bool skippedIntro;

    private void Start()
    {
        typewriter.Completed += OnTypewriterCompleted;

        skipButton.SetActive(watchedIntro.Value);
    }

    public void Skip()
    {
        skippedIntro = true;
        typewriter.Finish();
    }

    private void OnTypewriterCompleted()
    {
        skipButton.SetActive(false);

        watchedIntro.Value = true;

        StartCoroutine(WindFadeIn());
        IEnumerator WindFadeIn()
        {
            (var fadein, var fadeout) = skippedIntro
                ? (fastWindFadeIn, fastWindFadeOut)
                : (windFadeIn, windFadeOut);

            fadein.Start();
            while (!fadein.Done)
            {
                float percent = fadein.Evaluate();
                wind.material.SetFloat(windColorEdge, 1 - percent);
                windAudio.volume = percent * maxWindVolume;

                yield return null;
            }

            var color = blackout.color;
            color.a = 1;
            blackout.color = color;

            wind.material.SetFloat(windColorEdge, 1);
            wind.sortingOrder = 10;

            fadeout.Start();
            while (!fadeout.Done)
            {
                float percent = fadeout.Evaluate();
                windAudio.volume = percent * maxWindVolume;
                wind.material.SetFloat(windColorEdge, percent);

                yield return null;
            }

            UnityEngine.SceneManagement.SceneManager.LoadScene(loadScene);
        }
    }
}
