using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerAnimation : Player.Component
{
    [SerializeField] private MeshFilter meshFilter;
    [SerializeField] private Transform legPivot1, legPivot2;
    [SerializeField] private float legLength;
    [SerializeField] private float topLegWidth;
    [SerializeField] private float bodyBaseWidth;
    [SerializeField] private float bodyHeight;
    [SerializeField] private LayerMask groundMask;
    [SerializeField] private float forwardStepAngle;
    [SerializeField] private float maxLeanForward;

    private Mesh mesh;
    private int[] triangles;
    private Vector2[] uv;
    private Vector3[] vertices;

    private Vector2 footPosition1, footPosition2;
    private Vector2 center;

    private void Awake()
    {
        mesh = new Mesh();
        meshFilter.mesh = mesh;

        triangles = new[]
        {
            2, 1, 0,
            5, 4, 3,
            6, 7, 8,
        };

        uv = new Vector2[9];
        System.Array.Fill(uv, Vector2.zero);

        vertices = new Vector3[9];
        mesh.name = "Player Model";
        mesh.vertices = vertices;
        mesh.triangles = triangles;
    }

    private void Update()
    {
        center = transform.localPosition;

        Vector2 ConstrainFoot(Vector2 position, Vector2 pivot)
        {
            float distanceSqr = (position - pivot).sqrMagnitude;

            if (distanceSqr > legLength)
            {
                float angle = (90 - Movement.Facing * (90 + forwardStepAngle)) * Mathf.Deg2Rad;
                Vector2 stepDir = new(Mathf.Cos(angle), Mathf.Sin(angle));

                position = Vector2.ClampMagnitude(Physics2D.Raycast(pivot, stepDir, Mathf.Infinity, groundMask).point - pivot, legLength) + pivot;
            }

            return position;
        }

        Vector2 legExtent = Vector2.right * topLegWidth / 2f;

        Vector2 legPiv1 = legPivot1.localPosition;
        footPosition1 = ConstrainFoot(footPosition1, legPivot1.position);
        vertices[0] = transform.InverseTransformPoint(footPosition1);
        vertices[1] = legPiv1 + legExtent;
        vertices[2] = legPiv1 - legExtent;

        Vector2 legPiv2 = legPivot2.localPosition;
        footPosition2 = ConstrainFoot(footPosition2, legPivot2.position);
        vertices[3] = transform.InverseTransformPoint(footPosition2);
        vertices[4] = legPiv2 + legExtent;
        vertices[5] = legPiv2 - legExtent;

        Vector2 bodyOffset = Vector2.right * bodyBaseWidth / 2f;
        vertices[6] = center + new Vector2(maxLeanForward * Movement.SpeedPercent, bodyHeight).normalized * bodyHeight;
        vertices[7] = center + bodyOffset;
        vertices[8] = center - bodyOffset;

        mesh.vertices = vertices;
    }

    private void OnDrawGizmos()
    {
        if (triangles == null) return;

        for (int i = 0; i < triangles.Length; i += 3)
        {
            Gizmos.DrawLine(transform.position + vertices[triangles[i + 0]], transform.position + vertices[triangles[i + 1]]);
            Gizmos.DrawLine(transform.position + vertices[triangles[i + 1]], transform.position + vertices[triangles[i + 2]]);
            Gizmos.DrawLine(transform.position + vertices[triangles[i + 2]], transform.position + vertices[triangles[i + 0]]);
        }
    }
}
