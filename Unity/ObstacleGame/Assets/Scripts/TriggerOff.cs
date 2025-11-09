using UnityEngine;

public class  TriggerOff : MonoBehaviour
{
    [SerializeField] GameObject ObjectToTrigger;
    [SerializeField] GameController game;

    private void Start()
    {
        game = FindFirstObjectByType<GameController>();
    }


    private void OnTriggerEnter(UnityEngine.Collider other)
    {
        ObjectToTrigger.SetActive(false);
    }



}
