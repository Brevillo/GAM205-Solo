using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Reflection;
using System.Linq;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem.UI;
using System;
using System.Text;
#if UNITY_EDITOR
using UnityEditor;
#endif

public static class Util {

    #region Math

    public static T Increment<T>(this T enumerator) where T :Enum
        => Increment(enumerator, 1);
    public static T Increment<T>(this T enumerator, int increment) where T :Enum
        => (T)(IConvertible)(((int)(IConvertible)enumerator + increment) %Enum.GetValues(typeof(T)).Length);

    public static int Sign0(this float f) => f < 0 ? -1 : f > 0 ? 1 : 0;

    public static float RoundTo(this float f, int decimals) {
        float pow = Mathf.Pow(10, decimals);
        return Mathf.Round(f * pow) / pow;
    }

    public static Vector2 RoundTo(this Vector2 v, int decimals) {
        float pow = Mathf.Pow(10, decimals);
        return new(Mathf.Round(v.x * pow) / pow, Mathf.Round(v.y * pow) / pow);
    }

    public static float ToRad(this Vector2 v) => Mathf.Atan2(v.y, v.x);
    public static float ToDeg(this Vector2 v) => v.ToRad() * Mathf.Rad2Deg;

    public static float MapUnclamped(this float value, float min1, float max1, float min2, float max2)
        => (value - min1) / (max1 - min1) * (max2 - min2) + min2;

    public static float Map(this float value, float min1, float max1, float min2, float max2)
        => Mathf.Lerp(min2, max2, Mathf.Clamp01(Mathf.InverseLerp(min1, max1, value)));

    public static Vector2 MoveTowardsSeparate(Vector2 current, Vector2 target, Vector2 maxDelta) => new(
        Mathf.MoveTowards(current.x, target.x, maxDelta.x),
        Mathf.MoveTowards(current.y, target.y, maxDelta.y));

    public static Vector2 ConfineDirections(this Vector2 vector, int directions) {

        if (vector == Vector2.zero) return Vector2.zero;

        float mult = Mathf.PI * 2f / directions,
              angle = Mathf.Round(Mathf.Atan2(vector.y, vector.x) / mult) * mult;

        return new Vector2(Mathf.Cos(angle), Mathf.Sin(angle)) * vector.magnitude;
    }

    /// <summary> Returns the float with greatest absolute value. </summary>
    public static float MaxAbs(params float[] floats) {

        float max = 0,
              abs = 0;

        foreach (float f in floats) {

            float newAbs = Mathf.Abs(f);

            if (newAbs > abs) {
                abs = newAbs;
                max = f;
            }
        }

        return max;
    }

    public static Vector3 SmoothDampAngle(Vector3 current, Vector3 target, ref Vector3 velocity, float smoothTime)
        => SmoothDampAngleSeperate(current, target, ref velocity, Vector3.one * smoothTime, Vector3.positiveInfinity, Time.deltaTime);

    public static Vector3 SmoothDampAngleSeperate(Vector3 current, Vector3 target, ref Vector3 velocity, Vector3 smoothTime, Vector3 maxSpeed, float dt) => dt == 0 ? current : new(
        Mathf.SmoothDampAngle(current.x, target.x, ref velocity.x, smoothTime.x, maxSpeed.x, dt),
        Mathf.SmoothDampAngle(current.y, target.y, ref velocity.y, smoothTime.y, maxSpeed.y, dt),
        Mathf.SmoothDampAngle(current.z, target.z, ref velocity.z, smoothTime.z, maxSpeed.z, dt));

    public static Vector2 SmoothDampSeparate(Vector2 current, Vector2 target, ref Vector2 velocity, Vector2 smoothTime, Vector2 maxSpeed, float dt) => dt == 0 ? current : new(
        Mathf.SmoothDamp(current.x, target.x, ref velocity.x, smoothTime.x, maxSpeed.x, dt),
        Mathf.SmoothDamp(current.y, target.y, ref velocity.y, smoothTime.y, maxSpeed.y, dt));

    public static Vector2 ClampSeparate(Vector2 vector, Vector2 max) => new(
        Mathf.Clamp(vector.x, -max.x, max.x),
        Mathf.Clamp(vector.y, -max.y, max.y));

    public static Rect RectLerp(Rect r2, Rect r1, float t) => RectLerpUnclamped(r1, r2, Mathf.Clamp01(t));
    public static Rect RectLerpUnclamped(Rect r1, Rect r2, float t) => new() {
        size = Vector2.LerpUnclamped(r1.size, r2.size, t),
        center = Vector2.LerpUnclamped(r1.center, r2.center, t),
    };

    public static float InverseLerpUnclamped(this float f, float a, float b) => (f - a) / (b - a);

    public static Vector3 Flat(this Vector3 v) => new(v.x, 0, v.z);

    public static Vector2 SwapXY(this Vector2 v) => new(v.y, v.x);

    public static Vector2 Project(this Vector2 self, Vector2 onVector) {
        Vector2 normalized = onVector.normalized;
        return (self.x * normalized.x + self.y * normalized.y) * normalized;
    }

    #region 2D Line Clamping

    // https://www.desmos.com/calculator/ebefqgb8la

    /// <summary> Finds the closest point to point on the line bewteen v1 and v2.</summary>
    /// <param name="point"> The point to find the closest point to. </param>
    /// <param name="v1"> A point on the line. </param>
    /// <param name="v2"> A point on the line. </param>
    public static Vector2 ClosestPointOnLine(this Vector2 point, Vector2 v1, Vector2 v2) {

        if (v1.x == v2.x) return new Vector2(v1.x, point.y);
        if (v1.y == v2.y) return new Vector2(point.x, v1.y);
        if (v1 == v2) return v1;

        float slope = (v2.y - v1.y) / (v2.x - v1.x),
              x = (slope * v1.x - v1.y + point.y + 1f / slope * point.x) / (1f / slope + slope);
        return new Vector2(x, slope * (x - v1.x) + v1.y);
    }

    /// <summary> Finds the closest point to point on the line between v1 and v2 and returns what percent that point is between them. </summary>
    /// <param name="point"> The point to find the closest to. </param>
    /// <param name="v1"> A point on the line. </param>
    /// <param name="v2"> A point on the line. </param>
    public static float InverseLerpFromClosestPoint(this Vector2 point, Vector2 v1, Vector2 v2) {
        Vector2 close = point.ClosestPointOnLine(v1, v2);

        (float p1, float p2, float t) = v1.x != v2.x
            ? (v1.x, v2.x, close.x)
            : (v1.y, v2.y, close.y);

        return (t - p1) / (p2 - p1);
    }

    /// <summary> Finds the vector from point to the line between v1 and v2. </summary>
    /// <param name="point"> The point to find the distance from the line to. </param>
    /// <param name="v1"> A point on the line. </param>
    /// <param name="v2"> A point on the line. </param>
    public static Vector2 DistToLine(this Vector2 point, Vector2 v1, Vector2 v2)
        => Vector2.Lerp(v1, v2, Mathf.Clamp01(point.InverseLerpFromClosestPoint(v1, v2))) - point;

    /// <summary> Clamps the point to be distance away from the line segment between v1 and v2. </summary>
    /// <param name="point"> The point to clamp. </param>
    /// <param name="v1"> One end of the line. </param>
    /// <param name="v2"> One end of the line. </param>
    /// <param name="distance"> The distance to clamp from the line segment. </param>
    public static Vector2 ClampToLineWithinDistance(this Vector2 point, Vector2 v1, Vector2 v2, float distance) {
        Vector2 onLine = point + point.DistToLine(v1, v2);
        return onLine + Vector2.ClampMagnitude(point - onLine, distance);
    }

    #endregion

    // figured this out here: https://www.desmos.com/calculator/qqxdtyt4qo
    public static float DecayTo(this float x, float to, float decayRate)
        => to * (1f - 1f / (1f + Mathf.Max(0, x) / decayRate));

    public static float DecayFromTo(this float x, float from, float to, float decayRate)
        => from - x.DecayTo(from - to, decayRate);

    public static Vector3 DecayTo(this Vector3 x, float to, float decayRate) {
        float magnitude = x.magnitude;
        if (magnitude == 0) return Vector3.zero;
        Vector3 normalized = x / magnitude;
        return normalized * magnitude.DecayTo(to, decayRate);
    }

    #endregion

    #region Unity

    public static InputSystemUIInputModule Input(this EventSystem eventSystem)
        => (InputSystemUIInputModule)eventSystem.currentInputModule;

    public static void SetResolution(this Resolution resolution) => Screen.SetResolution(resolution.width, resolution.height, Screen.fullScreenMode, resolution.refreshRateRatio);

    public static string GetName(this UnityEngine.AI.NavMeshBuildSettings agent) => UnityEngine.AI.NavMesh.GetSettingsNameFromID(agent.agentTypeID);

    public static bool TryGetComponentInParent<T>(this Component thisComponent, out T component) where T : Component
        => thisComponent.gameObject.TryGetComponentInParent(out component);
    public static bool TryGetComponentInParent<T>(this GameObject gameObject, out T component) where T : Component
        => (component = gameObject.GetComponentInParent<T>()) != null;

    public static bool TryGetComponentInChildren<T>(this Component thisComponent, out T component) where T : Component
        => thisComponent.gameObject.TryGetComponentInChildren(out component);
    public static bool TryGetComponentInChildren<T>(this GameObject gameObject, out T component) where T : Component
        => (component = gameObject.GetComponentInChildren<T>(true)) != null;

    public static T[] FindObjectsOfTypeI<T>(bool includeInactive) {

        List<T> found = new();

        foreach (var comp in UnityEngine.Object.FindObjectsOfType<Component>(includeInactive))
            if (comp is T t)
                found.Add(t);

        return found.ToArray();
    }

    public static T CopyComponent<T>(this GameObject go, T other) where T : Component {

        var component = go.AddComponent<T>();
        var type = component.GetType();
	    if (type != other.GetType()) return null; // type mis-match

	    var flags = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Default | BindingFlags.DeclaredOnly;
        var props = type.GetProperties(flags);

        foreach (var prop in props)
		    if (prop.CanWrite)
			    try {
				   prop.SetValue(component, prop.GetValue(other, null), null);
			    }
                catch { } // In case of NotImplementedException being thrown. For some reason specifying that exception didn't seem to catch it, so I didn't catch anything specific.

        var fields = type.GetFields(flags);

        foreach (var finfo in fields)
		    finfo.SetValue(component, finfo.GetValue(other));

	    return component;
    }

    public static Vector3 ScreenToCanvasPoint(this Canvas canvas, Vector3 point) => canvas.ViewportToCanvasPoint(Vector3.Scale(point, new Vector3(1f / Screen.width, 1f / Screen.height, 0f)));
    public static Vector3 WorldToCanvasPoint(this Canvas canvas, Camera camera, Vector3 point) => canvas.ViewportToCanvasPoint(camera.WorldToViewportPoint(point));
    public static Vector3 ViewportToCanvasPoint(this Canvas canvas, Vector3 point) => Vector3.Scale(point - new Vector3(0.5f, 0.5f, 0f), (canvas.transform as RectTransform).sizeDelta);

    // must be index in case T is a struct
    //public static bool TryFind<T>(this List<T> list,Predicate<T> match, out T found) {
    //    int index = list.FindIndex(match);
    //    bool success = index != -1;
    //    found = success ? list[index] : default(T);
    //    return success;
    //}

    public static Color Inverted(this Color color) => new(
            color.r == 0 ? 0 : 1f / color.r,
            color.g == 0 ? 0 : 1f / color.g,
            color.b == 0 ? 0 : 1f / color.b,
            color.a == 0 ? 0 : 1f / color.a);

    #endregion

    #region Editor
#if UNITY_EDITOR
    
    public static Predicate<EditorBuildSettingsScene> EqualsScene(SceneAsset scene) {
        string path = AssetDatabase.GetAssetPath(scene);
        return scene => scene.path == path;
    }

    public static void AddSceneToBuildSettings(SceneAsset scene) {

        var scenes = EditorBuildSettings.scenes.ToList();;

        if (scene != null && !scenes.Exists(EqualsScene(scene)))
            scenes.Add(new(AssetDatabase.GetAssetPath(scene), true));

        EditorBuildSettings.scenes = scenes.ToArray();
    }

    public static void RemoveSceneToBuildSettings(SceneAsset scene) {

        var scenes = EditorBuildSettings.scenes.ToList();

        if (scene != null)
            scenes.RemoveAll(EqualsScene(scene));

        EditorBuildSettings.scenes = scenes.ToArray();
    }

#endif
    #endregion

    #region C#

    public static string AddSpacesToSentence(this string text, bool preserveAcronyms = true)
    {
        if (string.IsNullOrWhiteSpace(text))
            return string.Empty;

        var newText = new StringBuilder(text.Length * 2);
        newText.Append(text[0]);

        for (int i = 1; i < text.Length; i++)
        {
            if (char.IsUpper(text[i]))
                if ((text[i - 1] != ' ' && !char.IsUpper(text[i - 1]))
                    || (preserveAcronyms && char.IsUpper(text[i - 1])
                    && i < text.Length - 1 && !char.IsUpper(text[i + 1])))
                    newText.Append(' ');

            newText.Append(text[i]);
        }

        return newText.ToString();
    }

    #endregion

    private class FlashData {
        public Renderer rend;
        public float endTime;
        public Coroutine coroutine;
        public MonoBehaviour component;
        public Material ogMaterial;
    }

    private static List<FlashData> flashingRends = new();
    public static Coroutine FlashMaterial(this Renderer rend, float duration, MonoBehaviour component, Material material,Action complete = null) {

        float endTime = Time.time + duration;

        int existingIndex = flashingRends.FindIndex(item => item.rend == rend && item.endTime > endTime);
        if (existingIndex != -1) return flashingRends[existingIndex].coroutine;

        flashingRends.RemoveAll(item => {

            if (item.rend == rend) {
                rend.material = item.ogMaterial;
                if (item.component != null) item.component.StopCoroutine(item.coroutine);
                return true;
            }

            return false;
        });

        var data = new FlashData {
            rend = rend,
            endTime = endTime,
            ogMaterial = rend.material,
        };

        return data.coroutine = component.StartCoroutine(Flash());

        IEnumerator Flash() {

            flashingRends.Add(data);
            rend.material = material;

            yield return new WaitForSeconds(duration);

            rend.material = data.ogMaterial;
            flashingRends.Remove(data);

            complete?.Invoke();
        }
    }
    public static void ChangeFlashMaterial(this Renderer rend, Material newMaterial) {

        var data = flashingRends.Find(data => data.rend == rend);

        if (data != null) data.ogMaterial = newMaterial;
        else rend.material = newMaterial;
    }
}
