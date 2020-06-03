using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderController : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        GetComponent<SpriteRenderer>().material.SetFloat("_AlphaValue", 0.3f);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
