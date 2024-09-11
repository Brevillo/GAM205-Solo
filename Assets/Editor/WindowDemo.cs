using UnityEditor;
using UnityEngine;

public class WindowDemo : EditorWindow
{
    private string worstString;

    [MenuItem("Window/Window Demo")]
    public static void OpenWindow()
    {
        GetWindow<WindowDemo>("Window Demo Epic Yay!");
    }

    private void OnGUI()
    {
        GUILayout.Label("Best Label", EditorStyles.boldLabel);

        worstString = GUILayout.TextField(worstString);
    }
}
