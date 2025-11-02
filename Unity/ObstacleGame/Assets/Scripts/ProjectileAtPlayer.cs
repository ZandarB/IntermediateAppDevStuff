using UnityEngine;

public class ProjectileAtPlayer : MonoBehaviour
{
    [SerializeField] float speed = 20f;
    private Vector3 targetPosition;
    [SerializeField] PlayerController player;

    public void SetTargetPosition(Vector3 position)
    {
        targetPosition = position;
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
            if (player != null)
            {
                player.TakeDamage(10);
            }

            Destroy(gameObject); 
        }
        else
        {
            Destroy(gameObject);
        }
    }
}
