using System.Reflection;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public abstract class DebugCanvasBase : MonoBehaviour
{
    [SerializeField] private GameObject content;
    [SerializeField] private Transform buttonParent;
    [SerializeField] private Button buttonPrefab;
    [SerializeField] private GameplayInput input;

    private void Start()
    {
        var methods = GetType()
            .GetMethods(BindingFlags.DeclaredOnly |
                        BindingFlags.Public |
                        BindingFlags.NonPublic |
                        BindingFlags.Instance |
                        BindingFlags.Static);

        foreach (var method in methods)
        {
            var button = Instantiate(buttonPrefab, buttonParent);
            button.onClick.AddListener(() => method.Invoke(this, null));
            button.GetComponentInChildren<TextMeshProUGUI>().text = method.Name;
        }
    }

    private void Update()
    {
        bool visible = input.DebugCanvas.Pressed;
        content.SetActive(visible);
    }
}

