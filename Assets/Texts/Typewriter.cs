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
    [SerializeField] private float lineDelay;
    [SerializeField] private float punctuationDelay;
    [SerializeField] private bool playOnStart;
    [SerializeField] private float delay;

    private static readonly List<char> punctuation = new() { '!', '.', ',', ':', ';', '?', };

    private Coroutine type;
    private bool done;

    public bool Done => done;
    public event Action Completed;

    public void Finish()
    {
        if (type == null || done) return;

        StopCoroutine(type);

        textMesh.maxVisibleCharacters = int.MaxValue;

        done = true;
        Completed?.Invoke();
    }

    private void Start()
    {
        if (playOnStart)
        {
            Type();
        }
    }

    public void TypeText(string text)
    {
        textMesh.text = text;
        Type();
    }

    public void Type()
    {
        type = StartCoroutine(Coroutine());
        IEnumerator Coroutine()
        {
            done = false;

            var tags = new System.Text.RegularExpressions.Regex(@"<[^>]*>");

            string text = tags.Replace(textMesh.text, string.Empty);
            int length = text.Length;

            textMesh.maxVisibleCharacters = 0;

            yield return new WaitForSeconds(delay);

            for (int i = 0; i < length; i++)
            {
                textMesh.maxVisibleCharacters = i + 1;

                var c = text[i];

                if (c != ' ')
                {
                    audioSource.PlayOneShot(typeSound);
                }

                float delay
                    = c == '\n' ? lineDelay
                    : punctuation.Contains(c) ? punctuationDelay
                    : charDelay;

                yield return new WaitForSeconds(delay);
            }

            done = true;
            type = null;
            Completed?.Invoke();
        }
    }
}
