using UnityEngine;

public class GameWin : MonoBehaviour
{
    [SerializeField] GameObject gameWinPanel;
    [SerializeField] PlayerController player;


    private void OnTriggerEnter(Collider other)
    {

        gameWinPanel.SetActive(true);
        player.LockMovement();

    }
}
