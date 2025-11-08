using UnityEngine;

public class  TriggerOff : MonoBehaviour
{
    [SerializeField] GameObject ObjectToTrigger;

    private void OnTriggerEnter(UnityEngine.Collider other)
    {
        ObjectToTrigger.SetActive(false);
    }

}
