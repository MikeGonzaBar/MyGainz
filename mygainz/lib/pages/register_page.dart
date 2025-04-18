import 'package:flutter/material.dart';
import 'package:mygainz/widgets/input_field.dart';
import 'package:mygainz/widgets/unit_measurement_input_field.dart';
import 'package:mygainz/widgets/percentage_input_field.dart';

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

  void _submit() {
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
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      birthdayController.text =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    }
                  },
                  child: AbsorbPointer(
                    child: CustomInputField(
                      controller: birthdayController,
                      hintText: 'Birthday',
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Fitness Info Section ──────────────
                const Text(
                  'Fitness Information 💪',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "We won't use this data for anything but for your own tracking of progress! 😉",
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MeasurementInputField(
                        controller: heightController,
                        onUnitChanged: updateHeightUnit,
                        selectedUnit: heightUnit,
                        measurementType: 'height',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MeasurementInputField(
                        controller: weightController,
                        onUnitChanged: updateHWightUnit,
                        selectedUnit: weightUnit,
                        measurementType: 'weight',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 24),

                Center(
                  child: ElevatedButton(
                    onPressed: _submit,
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
                    child: const Text(
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
  }
}
