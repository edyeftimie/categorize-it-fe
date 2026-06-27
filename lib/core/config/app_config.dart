const String appBaseUrl = String.fromEnvironment(
  'BASE_URL',
  // defaultValue: 'http://10.0.2.2:5272', // Android emulator → localhost
  // defaultValue: 'http://192.168.1.13:5272',
  defaultValue: 'http://localhost:5272',
);