using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using OliverBeebe.UnityUtilities.Runtime;
using UnityEngine.UI;
using TMPro;

// to get shaders to work with UI masks : https://www.youtube.com/watch?v=RxW7_qgkXPo

public class PlayerHealth : Player.Component
{
    [SerializeField] private LayerMask groundMask;

    [SerializeField] private SmartCurve deathAnimation;
    [SerializeField] private SmartCurve respawnAnimtion;
    [SerializeField] private Image deathScreen;
    [SerializeField] private float deathFillDelay;
    [SerializeField] private float bodyDeathDelay;
    [SerializeField] private SmartCurve deathTextAnimation;
    [SerializeField] private float deathTextDelay;
    [SerializeField] private TextMeshProUGUI deathText;
    [SerializeField] private float startDeathTextSpacing;
    [SerializeField] private float endDeathTextSpacing;
    [SerializeField] private AudioSource deathAmbience;
    [SerializeField] private float maxDeathAmbienceVolume;
    [SerializeField] private float maxDeathAmbiencePitch;
    [SerializeField] private ShakeProfile2D deathBodyShake;
    [SerializeField] private SmartCurve deathBodyExpansion;
    [SerializeField] private Transform visuals;
    [SerializeField] private SoundEffect playerHurt;
    [SerializeField] private SmartCurve deathFlash;
    [SerializeField] private CanvasGroup deathFlashGroup;

    private static readonly int
        animationID = Shader.PropertyToID("_Animation"),
        centerID = Shader.PropertyToID("_Center");

    private Coroutine death;
    private Vector2 ogSpawn;

    private EffectsManager2D effects;

    public void Die()
    {
        if (death != null) return;

        death = StartCoroutine(Death());
    }

    private void Start()
    {
        ogSpawn = transform.position;
        effects = new();
    }

    private IEnumerator Death()
    {
        playerHurt.Play(this);

        Movement.enabled = false;
        Rigidbody.velocity = Vector2.zero;

        StartCoroutine(DeathFlash());
        IEnumerator DeathFlash()
        {
            deathFlash.Start();
            while (!deathFlash.Done)
            {
                deathFlashGroup.alpha = deathFlash.Evaluate();
                yield return null;
            }
        }

        StartCoroutine(BodyShake());
        IEnumerator BodyShake()
        {
            var bodyShake = effects.AddEffect(deathBodyShake.GetActiveEffect());

            deathBodyExpansion.Start();
            while (!bodyShake.Complete)
            {
                visuals.localScale = Vector3.one * (1 + deathBodyExpansion.Evaluate());
                visuals.localPosition = effects.Update();
                yield return null;
            }

            visuals.localPosition = Vector2.zero;
            visuals.localScale = Vector3.one;
        }

        yield return new WaitForSeconds(bodyDeathDelay);

        StartCoroutine(Text());
        IEnumerator Text()
        {
            yield return new WaitForSeconds(deathTextDelay);

            deathTextAnimation.Start();

            while (!deathTextAnimation.Done)
            {
                float percent = deathTextAnimation.Evaluate();
                deathText.characterSpacing = Mathf.Lerp(startDeathTextSpacing, endDeathTextSpacing, percent);

                yield return null;
            }
        }

        IEnumerator Animation(SmartCurve curve)
        {
            deathScreen.materialForRendering.SetVector(centerID, transform.position);

            curve.Start();
            while (!curve.Done)
            {
                float percent = curve.Evaluate();

                deathAmbience.volume = maxDeathAmbienceVolume * percent;
                deathAmbience.pitch = maxDeathAmbiencePitch * percent;
                deathScreen.materialForRendering.SetFloat(animationID, percent);

                yield return null;
            }
        }

        yield return Animation(deathAnimation);

        yield return new WaitForSeconds(deathFillDelay);

        transform.position = Checkpoint != null
            ? Physics2D.Raycast(Checkpoint.transform.position, Vector2.down, Mathf.Infinity, groundMask).point + Vector2.up * Collider.bounds.extents.y
            : ogSpawn;
        CameraMovement.SnapToTarget();

        yield return Animation(respawnAnimtion);

        Movement.enabled = true;
        Movement.ResetMovement();

        death = null;
    }
}
