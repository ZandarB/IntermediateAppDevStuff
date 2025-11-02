using TMPro;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{   
    [SerializeField] float moveSpeed = 10f;
    public int maxHealth = 100;
    public int health;
    [SerializeField] public TextMeshProUGUI healthText;

    void Start()
    {
        health = maxHealth;
    }

    void Update()
    {
        MovePlayer();
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
        health -= damage;
        healthText.text = ($"Health: " + health);
    }
}
