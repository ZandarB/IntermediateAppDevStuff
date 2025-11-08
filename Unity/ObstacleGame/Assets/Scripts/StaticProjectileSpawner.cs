using UnityEngine;

public class StaticProjectileSpawner : MonoBehaviour
{
    [SerializeField] GameObject projectilePrefab;
    [SerializeField] Transform spawnPoint;
    [SerializeField] float spawnInterval = 0.5f;
    [SerializeField] bool isRandom = false;

    bool waitUntilFire = false;

    float timer = 0f;

    void Update()
    {
        timer += Time.deltaTime;
        if (isRandom && !waitUntilFire)
        {
            RandomiseFireSpeed();
        }
        if (timer >= spawnInterval)
        {
            GameObject proj = Instantiate(projectilePrefab, spawnPoint.position, spawnPoint.rotation);
            proj.SetActive(true);
            timer = 0f;
            waitUntilFire = false;
        }
    }

    void RandomiseFireSpeed()
    {
        float randomValue = Random.Range(0.5f, 1.5f);
        spawnInterval = randomValue;
        waitUntilFire = true;

    }
}
