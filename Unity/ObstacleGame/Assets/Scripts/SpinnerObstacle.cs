using UnityEngine;

public class Spinner : MonoBehaviour
{
    [SerializeField] float xAngle = 0f;
    [SerializeField] float yAngle = 0f;
    [SerializeField] float zAngle = 0f;
     
    void Update()
    {
        transform.Rotate(xAngle, yAngle, zAngle);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag == "Player")
        {
            PlayerController player = collision.gameObject.GetComponent<PlayerController>();
            if (player != null)
            {
                player.TakeDamage(10);
            }
        }

   }
}
