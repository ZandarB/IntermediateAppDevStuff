using UnityEngine;

public class ProjectileAtPlayer : MonoBehaviour
{
    [SerializeField] float speed = 20f;
    private Vector3 targetPosition;
    [SerializeField] PlayerController player;

    private void Start()
    {
        player = GetComponent<PlayerController>();
    }
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
        //    if (collision.gameObject.CompareTag("Player") && !hasHit)
        //    {
        //        if (player != null)
        //        {
        //            Debug.Log("hello");
        //            player.TakeDamage(10);
        //        }
        //        hasHit = true;

        //        Destroy(gameObject); 
        //    }
        //    else
        //    {
        //        Destroy(gameObject);
        //    }
        //}
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
