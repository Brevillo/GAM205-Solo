using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using OliverBeebe.UnityUtilities.Runtime;

public class IntroManager : MonoBehaviour
{
    [SerializeField] private Typewriter typewriter;
    [SerializeField] private Renderer wind;
    [SerializeField] private SmartCurve windAnimation;
    [SerializeField] private AudioSource windAudio;
    [SerializeField] private float maxWindVolume;
    [SerializeField] private SmartCurve windFadeOut;
    [SerializeField] private SpriteRenderer blackout;
    [SerializeField] private Scene loadScene;

    private static readonly int windColorEdge = Shader.PropertyToID("_Color_Edge");

    private void Start()
    {
        typewriter.Completed += OnTypewriterCompleted;
    }

    private void OnTypewriterCompleted()
    {
        StartCoroutine(WindFadeIn());
        IEnumerator WindFadeIn()
        {
            windAnimation.Start();
            while (!windAnimation.Done)
            {
                float percent = windAnimation.Evaluate();
                wind.material.SetFloat(windColorEdge, 1 - percent);
                windAudio.volume = percent * maxWindVolume;

                yield return null;
            }

            windFadeOut.Start();
            while (!windFadeOut.Done)
            {
                float percent = windFadeOut.Evaluate();
                windAudio.volume = percent * maxWindVolume;

                var color = blackout.color;
                color.a = 1 - percent;
                blackout.color = color;

                yield return null;
            }

            UnityEngine.SceneManagement.SceneManager.LoadScene(loadScene);
        }
    }
}
