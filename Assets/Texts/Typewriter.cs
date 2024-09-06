using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using System;

public class Typewriter : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI textMesh;
    [SerializeField] private AudioSource audioSource;
    [SerializeField] private AudioClip typeSound;
    [SerializeField] private float charDelay;

    private bool done;
    public bool Done => done;
    public event Action Completed;

    public void Type(string text)
    {
        StartCoroutine(Coroutine(text));
    }

    private IEnumerator Coroutine(string text)
    {
        done = false;

        int length = text.Length;

        textMesh.maxVisibleCharacters = length;
        textMesh.text = text;

        for (int i = 0; i < length; i++)
        {
            textMesh.maxVisibleCharacters = i + 1;

            if (text[i] != ' ')
            {
                audioSource.PlayOneShot(typeSound);
            }

            yield return new WaitForSeconds(charDelay);
        }

        done = true;
        Completed?.Invoke();
    }
}
