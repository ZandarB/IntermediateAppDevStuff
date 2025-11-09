using System.Data;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameController : MonoBehaviour
{
    [SerializeField] PlayerController player;
    [SerializeField] GameObject GameOverCanvas;
    bool gameOver = false;

    void Update()
    {
        if (player.isDead == true && player.won == false)
        {
            GameOverCanvas.SetActive(true);
        }
    }

    public void ReturnToMenu()
    {
        SceneManager.LoadScene(0);
    }
}

