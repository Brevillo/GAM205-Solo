using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextTrigger : MonoBehaviour
{
    [SerializeField] private Typewriter typewriterPrefab;
    [SerializeField, TextArea] private string text;

    private bool triggered;

    private void OnTriggerEnter2D(Collider2D other)
    {
        if (triggered) return;
        triggered = true;

        Instantiate(typewriterPrefab).TypeText(text);
    }
}
