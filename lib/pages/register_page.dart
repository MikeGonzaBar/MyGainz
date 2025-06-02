import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mygainz/widgets/input_field.dart';
import 'package:mygainz/widgets/unit_measurement_input_field.dart';
import 'package:mygainz/widgets/percentage_input_field.dart';
import 'package:mygainz/providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  String heightUnit = 'm';
  String weightUnit = 'kg';
  final TextEditingController fatController = TextEditingController();
  final TextEditingController muscleController = TextEditingController();

  String? nameError,
      lastNameError,
      birthdayError,
      emailError,
      passwordError,
      confirmPasswordError;

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    birthdayController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    heightController.dispose();
    weightController.dispose();
    fatController.dispose();
    muscleController.dispose();
    super.dispose();
  }

  void updateHeightUnit(String newUnit) {
    setState(() {
      heightUnit = newUnit;
    });
  }

  void updateHWightUnit(String newUnit) {
    setState(() {
      weightUnit = newUnit;
    });
  }

  void _submit() async {
    setState(() {
      nameError = nameController.text.isEmpty ? 'Required' : null;
      lastNameError = lastNameController.text.isEmpty ? 'Required' : null;
      birthdayError = birthdayController.text.isEmpty ? 'Required' : null;
      emailError =
          emailController.text.isEmpty
              ? 'Required'
              : !RegExp(
                r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
              ).hasMatch(emailController.text)
              ? 'Invalid email'
              : null;
      passwordError =
          passwordController.text.isEmpty
              ? 'Required'
              : passwordController.text.length < 6
              ? 'Min 6 characters'
              : null;
      confirmPasswordError =
          confirmPasswordController.text.isEmpty
              ? 'Required'
              : passwordController.text != confirmPasswordController.text
              ? 'Passwords do not match'
              : null;
    });

    if ([
      nameError,
      lastNameError,
      birthdayError,
      emailError,
      passwordError,
      confirmPasswordError,
    ].every((e) => e == null)) {
      // Parse birthday
      DateTime? birthday;
      try {
        final parts = birthdayController.text.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          birthday = DateTime(year, month, day);
        }
      } catch (e) {
        setState(() {
          birthdayError = 'Invalid date format (DD/MM/YYYY)';
        });
        return;
      }

      if (birthday == null) {
        setState(() {
          birthdayError = 'Invalid date format (DD/MM/YYYY)';
        });
        return;
      }

      // Parse height and weight
      double? height, weight;
      try {
        height = double.parse(heightController.text);
        // Convert to cm if in meters
        if (heightUnit == 'm') {
          height = height * 100;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid height'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      try {
        weight = double.parse(weightController.text);
        // Convert to kg if in lbs
        if (weightUnit == 'lbs') {
          weight = weight * 0.453592;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid weight'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      print('--- SUBMITTED ---');
      print('Name: ${nameController.text}');
      print('LastName: ${lastNameController.text}');
      print('Birthday: ${birthdayController.text}');
      print('Email: ${emailController.text}');
      print('Password: ${passwordController.text}');
      print('Height: ${heightController.text}');
      print('Weight: ${weightController.text}');
      print('Fat: ${fatController.text}');
      print('Muscle: ${muscleController.text}');

      // Use AuthProvider to register user
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: nameController.text.trim(),
        lastName: lastNameController.text.trim(),
        dateOfBirth: birthday,
        height: height,
        weight: weight,
      );

      if (success) {
        // Registration successful - AuthWrapper will handle navigation
        print('Registration successful, user should be logged in');
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text("Register")),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Looks like it's your first time with us!\nLet us know more about yourself",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Credentials Section ──────────────
                    const Text(
                      'Credentials 🔐',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomInputField(
                      controller: emailController,
                      hintText: 'Email',
                      errorText: emailError,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInputField(
                            controller: passwordController,
                            hintText: 'Password',
                            obscure: true,
                            errorText: passwordError,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomInputField(
                            controller: confirmPasswordController,
                            hintText: 'Confirm Password',
                            obscure: true,
                            errorText: confirmPasswordError,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    // ─── Personal Info Section ──────────────
                    const Text(
                      'Personal Information 👤',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInputField(
                            controller: nameController,
                            hintText: 'Name',
                            errorText: nameError,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomInputField(
                            controller: lastNameController,
                            hintText: 'Last Name',
                            errorText: lastNameError,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomInputField(
                      controller: birthdayController,
                      hintText: 'Birthday (DD/MM/YYYY)',
                      errorText: birthdayError,
                    ),

                    const SizedBox(height: 24),
                    // ─── Body Measurements Section ──────────────
                    const Text(
                      'Body Measurements 📏',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: UnitMeasurementInputField(
                            controller: heightController,
                            hintText: 'Height',
                            currentUnit: heightUnit,
                            units: const ['m', 'cm'],
                            onUnitChanged: updateHeightUnit,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: UnitMeasurementInputField(
                            controller: weightController,
                            hintText: 'Weight',
                            currentUnit: weightUnit,
                            units: const ['kg', 'lbs'],
                            onUnitChanged: updateHWightUnit,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    // ─── Body Composition Section ──────────────
                    const Text(
                      'Body Composition (Optional) 💪',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: PercentageInputField(
                            controller: fatController,
                            hintText: 'Fat %',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PercentageInputField(
                            controller: muscleController,
                            hintText: 'Muscle %',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    // ─── Register Button ──────────────
                    Center(
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child:
                            authProvider.isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
