## NTT in Dart & Javascript

The same implementation of `Number Theoretic Transform` yields different results in Dart and JS.

All functions here in both languages have been tested independently and only the `ntt` and `nttInverse` implementations yields different results.

### Dart

```
dart run ntt.dart
```

### Javascript

```
node ntt.js
```

These scripts will check the result file from the other language and report the incorrect values. Keep in mind that the JS implementation yields the correct values as it is already used in other cryptographic implementations