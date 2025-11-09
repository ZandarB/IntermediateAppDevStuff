using UnityEngine;

public class ProjectileStraight : MonoBehaviour
{
    [SerializeField] float speed = 20f;

    void Update()
    {
        transform.Translate(Vector3.forward * speed * Time.deltaTime);
    }

    private void OnCollisionEnter(Collision collision)
    {
        Debug.Log("Hit object: " + collision.gameObject.name + " with tag: " + collision.gameObject.tag);
        if (collision.gameObject.CompareTag("Player"))
        {
            PlayerController player = collision.gameObject.GetComponent<PlayerController>();
            if (player != null)
            {
                player.TakeDamage(10);
                Destroy(gameObject);
            }
        }
        else if (!collision.gameObject.CompareTag("Ground") && !collision.gameObject.CompareTag("Trigger"))
        {
            Destroy(gameObject);
        }   

    }
}