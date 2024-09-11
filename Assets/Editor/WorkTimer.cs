using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace OliverBeebe.UnityUtilities.Runtime
{
    [CreateAssetMenu(menuName = "Oliver Utilities/Editor/Work Timer")]
    public class WorkTimer : ScriptableObject
    {
        [SerializeField] private Segment activeSegment = Segment.New();
        [SerializeField] private List<Segment> savedSegments = new();

        [SerializeField] private DataName[] outputFormatting = new[]
        {
            DataName.Name,
            DataName.Description,
            DataName.Start,
            DataName.End,
            DataName.Duration,
        };

        private enum RecordingState
        {
            Inactive,
            Prepping,
            Recording,
        }

        [SerializeField] private RecordingState recordingState;
        [SerializeField] private bool outputFoldout;

        private enum DataName
        {
            Name,
            Description,
            Start,
            End,
            Duration,
        }

        private static readonly Dictionary<DataName, Func<Segment, string>> dataNameToValue = new()
        {
            { DataName.Name,        segment => segment.name },
            { DataName.Description, segment => segment.description },
            { DataName.Start,       segment => segment.StartTime.ToString() },
            { DataName.End,         segment => segment.EndTime.ToString() },
            { DataName.Duration,    segment => segment.DurationSpan.ToString() }
        };

        [Serializable]
        private struct Segment
        {
            public static Segment New() => new()
            {
                start = DateTime.UtcNow.ToFileTimeUtc(),
                segmentID = Guid.NewGuid().ToString(),
            };

            public void Reset()
            {
                end = start = DateTime.UtcNow.ToFileTimeUtc();
            }

            public void Update()
            {
                var endTime = DateTime.UtcNow;
                end = endTime.ToFileTimeUtc();
                duration = endTime.Subtract(DateTime.FromFileTimeUtc(start)).Ticks;
            }

            public string name;
            [TextArea(minLines: 3, maxLines: int.MaxValue)]
            public string description;
            public long start, end;
            public long duration;

            public string segmentID;
            public bool copyData;
            public bool copied;

            public readonly DateTime StartTime => DateTime.FromFileTimeUtc(start);
            public readonly DateTime EndTime => DateTime.FromFileTimeUtc(end);
            public readonly TimeSpan DurationSpan => TimeSpan.FromTicks(duration);

            public readonly TimeSpan ActiveDurationSpan => DateTime.UtcNow.Subtract(DateTime.FromFileTimeUtc(start));

            #region Editor
            #if UNITY_EDITOR

            [CustomPropertyDrawer(typeof(Segment))]
            private class SegmentPropertyDrawer : PropertyDrawer
            {
                private const int
                    spaces = 8,
                    lines = 11;

                public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
                {
                    EditorGUI.BeginChangeCheck();

                    position.height = EditorGUIUtility.singleLineHeight;

                    EditorGUI.PropertyField(position, property.FindPropertyRelative(nameof(name)));

                    IncrementPosition(height: 6);
                    EditorGUI.PropertyField(position, property.FindPropertyRelative(nameof(description)));

                    IncrementPosition(spacing: 6);

                    var durationSpan = TimeSpan.FromTicks(property.FindPropertyRelative(nameof(duration)).longValue);
                    EditorGUI.LabelField(position, $"Total   {durationSpan}");

                    IncrementPosition();
                    TimeLabel(nameof(start), "Start   ");

                    IncrementPosition();
                    TimeLabel(nameof(end), "End     ");

                    IncrementPosition();
                    string copyButtonLabel = property.FindPropertyRelative(nameof(copied)).boolValue
                        ? "Data Copied to Clipboard! :)"
                        : "Copy Data to Clipboard";
                    property.FindPropertyRelative(nameof(copyData)).boolValue = GUI.Button(position, copyButtonLabel);

                    EditorGUI.EndChangeCheck();

                    void IncrementPosition(float spacing = 1, float height = 1)
                    {
                        position.height = EditorGUIUtility.singleLineHeight * height;
                        position.y += EditorGUIUtility.singleLineHeight * spacing + EditorGUIUtility.standardVerticalSpacing;
                    }

                    void TimeLabel(string name, string label)
                    {
                        var prop = property.FindPropertyRelative(name);
                        var time = DateTime.FromFileTimeUtc(prop.longValue);

                        EditorGUI.LabelField(position, $"{label}{time}");
                    }
                }

                public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
                    => lines * EditorGUIUtility.singleLineHeight + spaces * EditorGUIUtility.standardVerticalSpacing;
            }

            #endif
            #endregion
        }

        public void NewSegment()
        {
            activeSegment = Segment.New();
            recordingState = RecordingState.Prepping;
        }

        public void SaveSegment()
        {
            activeSegment.Update();

            int existing = savedSegments.FindIndex(segment => segment.segmentID == activeSegment.segmentID);
            if (existing == -1)
            {
                savedSegments.Add(activeSegment);
            }
            else
            {
                savedSegments[existing] = activeSegment;
            }
        }

        public void StartRecording()
        {
            activeSegment.Reset();
            recordingState = RecordingState.Recording;
        }

        public void StopRecording()
        {
            recordingState = RecordingState.Inactive;
        }

        #region Editor
        #if UNITY_EDITOR

        string GetSegmentData(Segment segment) => string.Join("\t", outputFormatting.Select(dataName => dataNameToValue[dataName].Invoke(segment)));

        [CustomEditor(typeof(WorkTimer))]
        private class WorkTimerEditor : UnityEditor.Editor
        {
            private WorkTimer Timer => target as WorkTimer;

            public override void OnInspectorGUI()
            {
                EditorGUI.BeginChangeCheck();
                serializedObject.UpdateIfRequiredOrScript();

                static bool Foldout(ref bool foldout, string label) => foldout = EditorGUILayout.Foldout(foldout, label, true);

                var state = Timer.recordingState;

                if (state != RecordingState.Prepping
                    && GUILayout.Button("New Segment"))
                {
                    Timer.NewSegment();
                }

                if (state == RecordingState.Prepping
                    && GUILayout.Button("Start Recording"))
                {
                    Timer.StartRecording();
                }

                if (state == RecordingState.Recording)
                {
                    Timer.SaveSegment();

                    if (GUILayout.Button("Stop Recording"))
                    {
                        Timer.StopRecording();
                    }
                }

                EditorGUILayout.Space();

                var activeSegmentProp = serializedObject.FindProperty(nameof(WorkTimer.activeSegment));
                var activeSegment = Timer.activeSegment;

                if (state != RecordingState.Inactive)
                {
                    EditorGUILayout.PropertyField(activeSegmentProp.FindPropertyRelative(nameof(Segment.name)));
                    EditorGUILayout.PropertyField(activeSegmentProp.FindPropertyRelative(nameof(Segment.description)));
                }

                if (state == RecordingState.Recording)
                {
                    EditorGUILayout.LabelField($"Total   {activeSegment.DurationSpan}");
                    EditorGUILayout.LabelField($"Start   {activeSegment.StartTime}");
                    EditorGUILayout.LabelField($"End     {activeSegment.EndTime}");
                }

                EditorGUILayout.Space();

                EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(savedSegments)));

                EditorGUILayout.Space();

                if (Foldout(ref Timer.outputFoldout, "Output"))
                {
                    EditorGUI.indentLevel++;

                    EditorGUILayout.LabelField(string.Join("  |  ", Timer.outputFormatting));
                    EditorGUILayout.PropertyField(serializedObject.FindProperty(nameof(outputFormatting)));

                    if (Timer.savedSegments != null && Timer.savedSegments.Count > 0)
                    {
                        string dataString = string.Join("\n", Timer.savedSegments.Select(Timer.GetSegmentData));

                        string copyButtonLabel = EditorGUIUtility.systemCopyBuffer == dataString
                            ? "Data Copied to Clipboard! :)"
                            : "Copy Data to Clipboard";

                        EditorGUILayout.LabelField("Output Preview");
                        GUI.enabled = false;
                        EditorGUILayout.TextArea(dataString, new GUIStyle(GUI.skin.textArea)
                        {
                            wordWrap = false,
                            fixedHeight = EditorGUIUtility.singleLineHeight * 5,
                            fontSize = 6,
                        });
                        GUI.enabled = true;

                        if (GUILayout.Button(copyButtonLabel))
                        {
                            EditorGUIUtility.systemCopyBuffer = dataString;
                        }

                        if (GUILayout.Button("Print Data to Console"))
                        {
                            Debug.Log(dataString);
                        }
                    }
                    else
                    {
                        EditorGUILayout.HelpBox("No segments to output.", MessageType.Info);
                    }

                    EditorGUI.indentLevel--;
                }

                for (int i = 0; i < Timer.savedSegments.Count; i++)
                {
                    var segment = Timer.savedSegments[i];
                    string data = Timer.GetSegmentData(segment);

                    segment.copied = EditorGUIUtility.systemCopyBuffer == data;

                    if (segment.copyData)
                    {
                        EditorGUIUtility.systemCopyBuffer = Timer.GetSegmentData(segment);
                    }

                    Timer.savedSegments[i] = segment;
                }

                EditorGUI.EndChangeCheck();
                serializedObject.ApplyModifiedProperties();

                Repaint();
            }
        }

        #endif
        #endregion
    }
}
