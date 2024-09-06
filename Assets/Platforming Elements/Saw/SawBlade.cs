using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SawBlade : MonoBehaviour
{
    [SerializeField] private Transform sprite;
    [SerializeField] private float spinSpeed;

    private void Update()
    {
        sprite.localEulerAngles += Vector3.forward * spinSpeed * Time.deltaTime;
    }
}
