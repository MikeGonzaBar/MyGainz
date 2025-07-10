import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../profile/widgets/unit_measurement_input_field.dart';
import '../../profile/widgets/percentage_input_field.dart';
import '../../../core/providers/auth_provider.dart';

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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

  void updateWeightUnit(String newUnit) {
    setState(() {
      weightUnit = newUnit;
    });
  }

  void _register() async {
    setState(() {
      nameError = nameController.text.isEmpty ? 'Required' : null;
      lastNameError = lastNameController.text.isEmpty ? 'Required' : null;
      birthdayError = birthdayController.text.isEmpty ? 'Required' : null;
      emailError = emailController.text.isEmpty
          ? 'Required'
          : !RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
                  .hasMatch(emailController.text)
              ? 'Invalid email'
              : null;
      passwordError = passwordController.text.isEmpty
          ? 'Required'
          : passwordController.text.length < 6
              ? 'Min 6 characters'
              : null;
      confirmPasswordError = confirmPasswordController.text.isEmpty
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

      if (kDebugMode) {
        print('--- REGISTRATION DATA ---');
        print('Name: ${nameController.text}');
        print('Last Name: ${lastNameController.text}');
        print('Birthday: ${birthdayController.text}');
        print('Email: ${emailController.text}');
        print('Height: $height cm');
        print('Weight: $weight kg');
        print('Fat: ${fatController.text}%');
        print('Muscle: ${muscleController.text}%');
      }

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
        // Registration successful - Navigate back to AuthWrapper
        if (mounted) {
          Navigator.pop(context);
        }
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
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2027)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Create Account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF1B2027),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Welcome Message
                    Text(
                      'Welcome to MyGainz!',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1B2027),
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your account to start tracking your fitness journey',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 40),

                    // ─── Credentials Section ──────────────
                    Text(
                      'Credentials 🔐',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Email Field
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Fields Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _register(),
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ─── Personal Info Section ──────────────
                    Text(
                      'Personal Information 👤',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Name Fields Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: nameController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              prefixIcon: const Icon(Icons.person_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: lastNameController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              prefixIcon: const Icon(Icons.person_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Birthday Field with Date Picker
                    GestureDetector(
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now()
                              .subtract(const Duration(days: 365 * 25)),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          birthdayController.text =
                              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: birthdayController,
                          decoration: InputDecoration(
                            labelText: 'Birthday',
                            prefixIcon:
                                const Icon(Icons.calendar_today_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            hintText: 'DD/MM/YYYY',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your birthday';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Fitness Info Section ──────────────
                    Text(
                      'Fitness Information 💪',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We won't use this data for anything but for your own tracking of progress! 😉",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Height and Weight Row
                    Row(
                      children: [
                        Expanded(
                          child: MeasurementInputField(
                            controller: heightController,
                            selectedUnit: heightUnit,
                            onUnitChanged: updateHeightUnit,
                            measurementType: 'height',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MeasurementInputField(
                            controller: weightController,
                            selectedUnit: weightUnit,
                            onUnitChanged: updateWeightUnit,
                            measurementType: 'weight',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Fat and Muscle Row
                    Row(
                      children: [
                        Expanded(
                          child: BodyCompInputField(
                            controller: fatController,
                            measurementType: 'fat',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BodyCompInputField(
                            controller: muscleController,
                            measurementType: 'muscle',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B2027),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Create Account',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Sign In',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF1B2027),
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Note about completing profile later
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.orange.shade600,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Complete Your Profile Later',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'You can add your personal and fitness information from your profile settings after signing in.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
