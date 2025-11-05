using UnityEngine;

public class Player : MonoBehaviour
{

    private void OnCollisionEnter(Collision other) 
    {
        if (other.gameObject.tag != "Hit")
        {


        }        
    }
}
