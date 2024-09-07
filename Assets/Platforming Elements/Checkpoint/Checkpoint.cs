using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Checkpoint : MonoBehaviour
{
    [SerializeField] private ParticleSystem fireParticles;
    [SerializeField] private AudioSource fireAudio;

    private static List<Checkpoint> checkpoints;
    private static List<Checkpoint> Checkpoints => checkpoints ??= new();

    private void OnEnable()
    {
        Checkpoints.Add(this);
    }

    private void OnDisable()
    {
        Checkpoints.Remove(this);
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (!collision.TryGetComponent(out Player player)
            || !player.RegisterCheckpoint(this, out var oldCheckpoint)) return;

        if (oldCheckpoint != null)
        {
            oldCheckpoint.Activate(false);
        }

        Activate(true);
    }

    private void Activate(bool activate)
    {
        if (activate)
        {
            fireParticles.Play(true);
            fireAudio.Play();
        }
        else
        {
            fireParticles.Play(false);
            fireAudio.Stop();
        }
    }
}
