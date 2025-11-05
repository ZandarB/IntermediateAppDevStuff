using UnityEngine;

public class ProjectileAtPlayer : MonoBehaviour
{
    [SerializeField] float speed = 20f;
    private Vector3 targetPosition;
    [SerializeField] PlayerController player;

    private void Start()
    {
        player = FindFirstObjectByType<PlayerController>();
    }
    public void SetTargetPosition(Vector3 position)
    {
        targetPosition = new Vector3(position.x, transform.position.y, position.z);
    }

    void Update()
    {
        transform.position = Vector3.MoveTowards(transform.position, targetPosition, speed * Time.deltaTime);

        if (Vector3.Distance(transform.position, targetPosition) < 0.1f)
        {
            Destroy(gameObject);
        }
    }
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            player.TakeDamage(10);

            Destroy(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }
}
