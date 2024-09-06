using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using OliverBeebe.UnityUtilities.Runtime;

public class PlayerHealth : MonoBehaviour
{
    [SerializeField] private AnimationCurve deathAnimationCurve;
    [SerializeField] private float deathAnimationDuration;
    [SerializeField] private SpriteRenderer deathScreen;

    private static readonly int
        animationID = Shader.PropertyToID("_Animation"),
        centerID = Shader.PropertyToID("_Center");

    private float deathAnimationPercent;

    private enum State { Alive, Dying, Dead }

    private State state;

    public void Die()
    {
        if (state != State.Alive) return;

        state = State.Dying;
        deathScreen.material.SetVector(centerID, transform.position);
    }

    private void Update()
    {
        switch (state)
        {
            case State.Alive:
                break;

            case State.Dying:

                deathAnimationPercent += Time.deltaTime / deathAnimationDuration;

                deathScreen.material.SetFloat(animationID, deathAnimationCurve.Evaluate(deathAnimationPercent));

                break;
        }
    }
}
