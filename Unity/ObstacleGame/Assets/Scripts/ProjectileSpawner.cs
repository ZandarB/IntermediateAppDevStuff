using UnityEngine;
using System;

public class ProjectileSpawner : MonoBehaviour
{
    [SerializeField] GameObject projectilePrefab;
    [SerializeField] Transform spawnPoint;
    [SerializeField] Transform player;
    float spawnInterval = 2f;
    float timer = 0f;

    Vector3 playerPosition;

    void Start()
    {

    }

    void Update()
    {
        timer += Time.deltaTime;

        if (timer >= spawnInterval)
        {
            playerPosition = player.transform.position;
            GameObject proj = Instantiate(projectilePrefab, spawnPoint.position, spawnPoint.rotation);
            proj.SetActive(true);
            timer = 0f;
            ProjectileAtPlayer projScript = proj.GetComponent<ProjectileAtPlayer>();
            if (projScript != null)
            {
                projScript.SetTargetPosition(player.position); 
            }
        }
    }
}
