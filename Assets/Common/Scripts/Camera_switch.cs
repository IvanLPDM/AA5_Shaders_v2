using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Camera_switch : MonoBehaviour
{
    public Camera[] cameras; 

    void Start()
    {
        ActivateCamera(0);
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1)) ActivateCamera(0);
        if (Input.GetKeyDown(KeyCode.Alpha2)) ActivateCamera(1);
        if (Input.GetKeyDown(KeyCode.Alpha3)) ActivateCamera(2);
        if (Input.GetKeyDown(KeyCode.Alpha4)) ActivateCamera(3);
        if (Input.GetKeyDown(KeyCode.Alpha5)) ActivateCamera(4);
    }

    void ActivateCamera(int index)
    {
        for (int i = 0; i < cameras.Length; i++)
        {
            if (cameras[i] != null)
                cameras[i].gameObject.SetActive(i == index);
        }
    }
}
