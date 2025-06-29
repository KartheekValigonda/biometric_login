import 'package:flutter/material.dart';
import 'package:biometric_login/screens/home_screen.dart';
import 'package:biometric_login/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoadingBiometric = false;
  bool _isLoadingPin = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    bool canUseBiometrics = await _authService.canCheckBiometrics();
    if (!canUseBiometrics && mounted) {
      setState(() {
        _errorMessage = 'Biometric authentication is not available. Please use PIN.';
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    setState(() {
      _isLoadingBiometric = true;
      _errorMessage = '';
    });

    try {
      bool authenticated = await _authService.authenticateWithBiometrics();
      if (authenticated) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Biometric authentication failed. Please try again or use PIN.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingBiometric = false;
      });
    }
  }

  Future<void> _authenticateWithPin() async {
    setState(() {
      _isLoadingPin = true;
      _errorMessage = '';
    });

    try {
      bool authenticated = await _authService.authenticateWithPin(_pinController.text);
      if (authenticated) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid PIN. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingPin = false;
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF102E50),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 200,),
            Container(
              height: 700,
              decoration: BoxDecoration(
                  color: Color(0xFFF4F6FF),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(100))
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    SizedBox(height: 50,),
                    Text(
                      'Sign In',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF102E50)),
                    ),
                    SizedBox(height: 50),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Enter 4-digit PIN',
                        labelStyle: TextStyle(color: Color(0xFF102E50)),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                    ),
                    SizedBox(height: 6),
                    TextField(
                      controller: _pinController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm PIN',
                        labelStyle: TextStyle(color: Color(0xFF102E50)),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoadingPin || _isLoadingBiometric ? null : _authenticateWithPin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF102E50),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: _isLoadingPin
                          ? const SizedBox(

                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white),),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoadingBiometric || _isLoadingPin ? null : _authenticateWithBiometrics,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF102E50),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: _isLoadingBiometric
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Use Fingerprint', style: TextStyle(fontSize: 16, color: Colors.white),),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}