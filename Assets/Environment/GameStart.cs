using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using OliverBeebe.UnityUtilities.Runtime;

public class GameStart : MonoBehaviour
{
    [SerializeField] private SmartCurve windFadeIn;
    [SerializeField] private AudioSource windAudio;
    [SerializeField] private AudioSource bellsAudio;
    [SerializeField] private CanvasGroup blackout;
    [SerializeField] private SoundEffect doorClose;
    [SerializeField] private float fadeinDelay;
    [SerializeField] private float doorDelay;

    private void Start()
    {
        StartCoroutine(Sequence());
    }

    private IEnumerator Sequence()
    {
        blackout.alpha = 1;

        float windVolume = windAudio.volume;
        float bellsVolume = bellsAudio.volume;
        windAudio.volume = 0;
        bellsAudio.volume = 0;

        yield return new WaitForSeconds(doorDelay);

        doorClose.Play(this);

        yield return new WaitForSeconds(fadeinDelay);

        windFadeIn.Start();

        while (!windFadeIn.Done)
        {
            float percent = windFadeIn.Evaluate();

            windAudio.volume = windVolume * percent;
            bellsAudio.volume = bellsVolume * percent;
            blackout.alpha = 1 - percent;

            yield return null;
        }
    }
}
