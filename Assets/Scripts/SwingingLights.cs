using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwingingLights : MonoBehaviour {

    public Transform myTransform; 
    // Start is called before the first frame update
    void Start() {
    }

    // Update is called once per frame
    void Update(){
        float x = Mathf.Sin(Time.fixedTime);
        float y = Mathf.Cos(Time.fixedTime);
        myTransform.position = new Vector3 (x, 8, y);
    }
}
