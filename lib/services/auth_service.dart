import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _pinKey = 'user_pin';
  static const String _defaultPin = '1234'; // Default PIN for demo purposes

  Future<bool> canCheckBiometrics() async {
    try {
      bool canCheck = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      bool canCheckBiometrics = await this.canCheckBiometrics();
      if (!canCheckBiometrics) {
        throw Exception('Biometric authentication is not available on this device');
      }

      // Check if biometric characteristics have changed
      await _handleBiometricChanges();

      return await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      if (e.toString().contains(auth_error.notAvailable)) {
        throw Exception('Biometric authentication is not available on this device');
      } else if (e.toString().contains(auth_error.notEnrolled)) {
        throw Exception('No biometric credentials enrolled. Please set up biometrics in device settings.');
      } else if (e.toString().contains(auth_error.passcodeNotSet)) {
        throw Exception('Device passcode not set. Please enable passcode in device settings.');
      }
      throw Exception('Authentication error: $e');
    }
  }

  Future<void> _handleBiometricChanges() async {
    // In a real app, you might want to store a hash of enrolled biometrics
    // or check with a server to verify if biometric data has changed
    // For this demo, we'll just check if biometrics are still available
    List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
    if (availableBiometrics.isEmpty) {
      throw Exception('No biometrics available. Please set up biometrics in device settings.');
    }
  }

  Future<bool> authenticateWithPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // For demo purposes, use default PIN if none is set
      String? storedPin = prefs.getString(_pinKey);
      if (storedPin == null) {
        await prefs.setString(_pinKey, _defaultPin);
        storedPin = _defaultPin;
      }
      return pin == storedPin;
    } catch (e) {
      throw Exception('PIN authentication error: $e');
    }
  }
}