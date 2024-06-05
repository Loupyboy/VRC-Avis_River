
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using VRC.SDK3.Avatars.Components;
using VRC.SDK3.Avatars.ScriptableObjects;
using VRC.SDKBase;
using System.Text.RegularExpressions;
using UnityEditor.Animations;
using System.Linq;

public class AndroidMaterialSwap {

    [MenuItem("Tools/Uber/AndroidMaterialSwap/Swap to _Android Materials")]
    public static void Swap()
    {   
        swap(".mat", "_Android.mat");
    }
    [MenuItem("Tools/Uber/AndroidMaterialSwap/Swap back")]
    public static void Unswap() {
        swap("_Android.mat", ".mat");
    }

    public static void swap(string fromPattern, string toPattern) {
        var allObjects = Object.FindObjectsOfType<GameObject>();
        foreach (var go in allObjects) {
            if (go.name == "ubertest_TorusKnot_1") Debug.Log("ding");
            if (go.activeInHierarchy) {
                Renderer mr = go.GetComponent<MeshRenderer>();
                Renderer smr = go.GetComponent<SkinnedMeshRenderer>();
                Renderer r = mr == null ? smr : mr;
                if (r != null) {
                    var mats = (Material[])r.sharedMaterials.Clone();
                    var modified = false;
                    for (var i = 0; i < mats.Length; i++) {
                        var mat = mats[i];
                        var path = AssetDatabase.GetAssetPath(mat);
                        var newPath = path.Replace(fromPattern, toPattern);
                        var newMat = AssetDatabase.LoadAssetAtPath<Material>(newPath);
                        if (newMat != null) {
                            modified = true;
                            mats[i] = newMat;
                        }
                    }
                    if (modified) {
                        r.sharedMaterials = mats;
                    }
                }
            }
        }
        AssetDatabase.SaveAssets();
    }
}
