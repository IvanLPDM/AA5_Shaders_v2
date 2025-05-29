using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Depth : MonoBehaviour
{
    public Material material;     
    public string propertyName = "_YPos"; 
    public Transform targetObject; 

    void Update()
    {
        if (material != null && targetObject != null)
        {

            float shaderValue = targetObject.transform.position.y * -1 + 0.2f;
            material.SetFloat(propertyName, shaderValue);
        }
    }
}
