using UnityEngine;

public class ObjectRotation : MonoBehaviour
{
    [SerializeField] private float rotationSpeed = 0.15f;

    private bool isDragging;

    public void SetDragging(bool dragging)
    {
        isDragging = dragging;
    }

    public void Rotate(Vector2 delta)
    {
        // No rotation unless left click is currently held.
        if (!isDragging)
            return;

        transform.Rotate(
            Vector3.up,
            -delta.x * rotationSpeed,
            Space.World
        );

        transform.Rotate(
            Vector3.right,
            delta.y * rotationSpeed,
            Space.Self
        );
    }
}