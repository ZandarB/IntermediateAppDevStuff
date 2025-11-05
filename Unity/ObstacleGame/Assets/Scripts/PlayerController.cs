using TMPro;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    [SerializeField] float moveSpeed = 10f;
    public static int health = 100;
    public GameObject healthTextObject;
    public TextMeshProUGUI healthText;

    void Start()
    {
        healthText = healthTextObject.GetComponent<TextMeshProUGUI>();
        healthText.text = health.ToString();
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
        Debug.Log(health);
        healthText.text = $"Health: {health}";
    }
}
