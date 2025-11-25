class ApiConstants {
  // For Android Emulator use: http://10.0.2.2:3000/api/v1
  // For iOS Simulator use: http://localhost:3000/api/v1
  // For Physical Device use your machine's IP: http://192.168.x.x:3000/api/v1
  // Ngrok URL (Update this every time you restart ngrok)
  static const String baseUrl = 'https://pseudoofficially-lauraceous-dennis.ngrok-free.dev/api/v1';
  static const String registerUrl = '$baseUrl/auth/register';
  static const String loginUrl = '$baseUrl/auth/login';
}
