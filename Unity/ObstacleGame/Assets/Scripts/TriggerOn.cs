using UnityEngine;

public class  TriggerOn : MonoBehaviour
{
    [SerializeField] GameObject ObjectToTrigger;

    private void OnTriggerEnter(UnityEngine.Collider other)
    {
        ObjectToTrigger.SetActive(true);
    }

}
