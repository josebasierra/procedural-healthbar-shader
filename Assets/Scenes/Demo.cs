using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Demo : MonoBehaviour
{
    [SerializeField] List<GameObject> _healthObjects;

    [SerializeField] float _currentHealth = 0.8f;
    [SerializeField] float _incrementPerSecond = 1f;

    [SerializeField] float _timeToStart = 3f;

    int _healthNormalizedId = Shader.PropertyToID("_healthNormalized");
    float _signedIncrementPerSecond;

    bool _lifeIncrementEnabled = false;

    void Start()
    {
        _signedIncrementPerSecond = _incrementPerSecond;
        foreach (var healthObject in _healthObjects)
        {
            healthObject.GetComponent<Renderer>().material.SetFloat(_healthNormalizedId, _currentHealth);
        }
        Invoke(nameof(EnableLifeIncrement), _timeToStart);
    }

    void Update()
    {
        if (!_lifeIncrementEnabled) return;

        if (_currentHealth <= 0) _signedIncrementPerSecond = _incrementPerSecond;
        else if (_currentHealth >= 1) _signedIncrementPerSecond = -_incrementPerSecond;

        _currentHealth += Time.deltaTime * _signedIncrementPerSecond;

        foreach (var healthObject in _healthObjects)
        {
            healthObject.GetComponent<Renderer>().material.SetFloat(_healthNormalizedId, _currentHealth);
        }
    }

    void EnableLifeIncrement()
    {
        _lifeIncrementEnabled = true;
    }
}
