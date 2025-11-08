using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;


public class PlayerController : MonoBehaviour
{
    [SerializeField] float moveSpeed = 10f;
    public int health = 100;
    public GameObject healthTextObject;
    public TextMeshProUGUI healthText;
    public bool isDead = false;
    
    void Update()
    {
        MovePlayer();
        if (health <= 0 && isDead == false)
        {
            isDead = true;
        }
    }

    void MovePlayer()
    {
        float xValue = Input.GetAxis("Horizontal") * Time.deltaTime * moveSpeed;
        float yValue = 0f;
        float zValue = Input.GetAxis("Vertical") * Time.deltaTime * moveSpeed;
        transform.Translate(xValue, yValue, zValue);
    }

    public void TakeDamage(int damage)
    {   
        if (health <= 0)
        {
            return;
        }
        else
        {
            health -= damage;
            Debug.Log(health);
            healthText.text = $"Health: {health}";
        }

    }
}
