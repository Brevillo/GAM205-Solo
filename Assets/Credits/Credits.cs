using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Credits : MonoBehaviour
{
    [SerializeField] private float creditsDuration;
    [SerializeField] private RectTransform credits;

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
    }

    private void Update()
    {
        if (!started) return;

        creditsPercent += Time.deltaTime / creditsDuration;

        credits.localPosition = Vector2.Lerp(startPosition, endPosition, creditsPercent);
    }
}
