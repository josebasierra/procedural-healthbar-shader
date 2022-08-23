using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DemoController : MonoBehaviour
{
    [SerializeField] List<GameObject> _healthObjects;
    [SerializeField] float _currentHealth = 0.8f;
    [SerializeField] float _incrementPerSecond = 1f;

    float _signedIncrementPerSecond;

    void Start()
    {
        _signedIncrementPerSecond = _incrementPerSecond;
        foreach (var healthObject in _healthObjects)
        {
            healthObject.GetComponent<Renderer>().material.SetFloat("_healthNormalized", _currentHealth);
        }
    }

    void Update()
    { 
        if (_currentHealth <= 0) _signedIncrementPerSecond = _incrementPerSecond;
        else if (_currentHealth >= 1) _signedIncrementPerSecond = -_incrementPerSecond;

        _currentHealth += Time.deltaTime * _signedIncrementPerSecond;

        foreach (var healthObject in _healthObjects)
        {
            healthObject.GetComponent<Renderer>().material.SetFloat("_healthNormalized", _currentHealth);
        }
    }
}
