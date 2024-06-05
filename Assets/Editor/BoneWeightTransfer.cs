// BoneWeightTransfer v0.1

// Copyright(c) 2020 まじかる☆しげぽん

// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php
using UnityEngine;
using UnityEditor;

internal class BoneWeightTransfer : EditorWindow
{
    static BoneWeightTransfer window;
    public GameObject TargetObject;
    public GameObject SourceBone;
    public GameObject TargetBone;

    public int SourceBoneIndex;
    public int TargetBoneIndex;


    void OnGUI()
    {
        TargetObject = EditorGUILayout.ObjectField("処理対象オブジェクト", TargetObject, typeof(GameObject), true) as GameObject;
        SourceBone = EditorGUILayout.ObjectField("ウェイト移動元ボーン", SourceBone, typeof(GameObject), true) as GameObject;
        TargetBone = EditorGUILayout.ObjectField("ウェイト移動先ボーン", TargetBone, typeof(GameObject), true) as GameObject;

        EditorGUI.BeginDisabledGroup(TargetObject == null || SourceBone == null || TargetBone == null);
        if (GUILayout.Button("実行"))
        {
            Execute(TargetObject, SourceBone, TargetBone);
            Debug.Log("Success");
        }
        EditorGUI.EndDisabledGroup();

    }
    public void Execute(GameObject TargetObject, GameObject SourceBone, GameObject TargetBone)
    {
        SkinnedMeshRenderer skin = TargetObject.GetComponentInChildren<SkinnedMeshRenderer>();
        Mesh mesh = TargetObject.GetComponent<SkinnedMeshRenderer>().sharedMesh;


        for (int boneIndex = 0; boneIndex < skin.bones.Length; ++boneIndex)
        {
            if (skin.bones[boneIndex].name == SourceBone.name)
            {

                SourceBoneIndex = boneIndex;
            }
            if (skin.bones[boneIndex].name == TargetBone.name)
            {

                TargetBoneIndex = boneIndex;
            }
        }

        BoneWeight[] meshBoneweight = mesh.boneWeights;

        for (int i = 0; i < meshBoneweight.Length; ++i)
        {
            if (meshBoneweight[i].boneIndex0 == SourceBoneIndex)
            {
                meshBoneweight[i].boneIndex0 = TargetBoneIndex;
            }
            if (meshBoneweight[i].boneIndex1 == SourceBoneIndex)
            {
                meshBoneweight[i].boneIndex1 = TargetBoneIndex;
            }
            if (meshBoneweight[i].boneIndex2 == SourceBoneIndex)
            {
                meshBoneweight[i].boneIndex2 = TargetBoneIndex;
            }
            if (meshBoneweight[i].boneIndex3 == SourceBoneIndex)
            {
                meshBoneweight[i].boneIndex3 = TargetBoneIndex;
            }
        }
        mesh.boneWeights = meshBoneweight;

    }
    [MenuItem("Tools/BoneWeightTransfer")]
    public static void Open()
    {
        if (window == null)
        {
            window = CreateInstance<BoneWeightTransfer>();
            window.titleContent.text = "BoneWeightTransfer";
        }
        window.ShowUtility();

    }


}
