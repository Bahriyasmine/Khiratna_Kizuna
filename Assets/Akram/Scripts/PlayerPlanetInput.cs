using Unity.Cinemachine;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

public class PlayerPlanetInput : MonoBehaviour
{
    [SerializeField] private ObjectRotation objectRotation;
    [SerializeField] private Camera mainCamera;
    [SerializeField] private Transform tunisia;
    [SerializeField] private Transform tunisiaFront;
    [SerializeField] private CinemachineCamera earthCamera;
    [SerializeField] private CinemachineCamera tunisiaCamera;
    [SerializeField] private float zoomDistance = 1.2f;
    [SerializeField] private bool canRotate = true;
    [SerializeField] private Canvas canvas;

    [Header("Scene")]
    [SerializeField] private string sceneToLoad;

    private bool isZoomedIn;

    private void Awake()
    {
        canvas.gameObject.SetActive(false);
    }

    private void OnDrag(InputValue value)
    {
        objectRotation.SetDragging(
            canRotate && value.Get<float>() > 0.5f
        );
    }

    private void OnLook(InputValue value)
    {
        if (canRotate)
            objectRotation.Rotate(value.Get<Vector2>());
    }

    private void OnAttack(InputValue value)
    {
        if (!value.isPressed)
            return;

        // Second click after zooming loads the scene.
        if (isZoomedIn)
        {
            SceneManager.LoadScene(sceneToLoad);
            return;
        }

        // First click must hit Tunisia.
        Ray ray = mainCamera.ScreenPointToRay(
            Mouse.current.position.ReadValue()
        );

        if (!Physics.Raycast(ray, out RaycastHit hit) ||
            (hit.transform != tunisia &&
             !hit.transform.IsChildOf(tunisia)))
            return;

        Vector3 cameraPosition =
            tunisia.position + tunisiaFront.forward * zoomDistance;

        Quaternion cameraRotation = Quaternion.LookRotation(
            tunisia.position - cameraPosition,
            tunisiaFront.up
        );

        tunisiaCamera.transform.SetPositionAndRotation(
            cameraPosition,
            cameraRotation
        );

        earthCamera.Priority = 0;
        tunisiaCamera.Priority = 10;

        canRotate = false;
        isZoomedIn = true;

        objectRotation.SetDragging(false);
        canvas.gameObject.SetActive(true);
    }
}