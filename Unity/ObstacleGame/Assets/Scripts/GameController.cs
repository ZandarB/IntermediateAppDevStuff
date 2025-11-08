using System.Data;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameController : MonoBehaviour
{
    [SerializeField] PlayerController player;
    [SerializeField] GameObject GameOverCanvas;

    void Update()
    {
        if (player.isDead == true)
        {
            GameOverCanvas.SetActive(true);
        }
    }

    public void ReturnToMenu()
    {
        SceneManager.LoadScene(0);
    }
}
