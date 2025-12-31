import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:silentvoice/screens/helper_login_screen.dart';
import 'package:silentvoice/screens/user_pin_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;
  void _handleNext() {
    if (selectedRole == null) return;

    if (selectedRole == 'USER') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => UserPinScreen(role: PinRole.user)),
      );
    } else if (selectedRole == 'HELPER') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HelperLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 40),
                Center(
                  child: Text(
                    'Welcome',
                    style: GoogleFonts.allura(
                      fontSize: 90,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 35),

                Text(
                  'Continue as',
                  style: GoogleFonts.allura(
                    fontSize: 50,
                    color: const Color.fromARGB(255, 116, 115, 115),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 430,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 20,
                        left: MediaQuery.of(context).size.width / 2 - 165,
                        child: _buildRoleCircle(
                          'HELPER',
                          size: 175,
                          isSelected: selectedRole == 'HELPER',
                          onTap: () {
                            setState(() {
                              selectedRole = 'HELPER';
                            });
                          },
                        ),
                      ),
                      Positioned(
                        top: 98,
                        left: MediaQuery.of(context).size.width / 2 - 20,
                        child: _buildRoleCircle(
                          'USER',
                          size: 190,
                          isSelected: selectedRole == 'USER',
                          onTap: () {
                            setState(() {
                              selectedRole = 'USER';
                            });
                          },
                        ),
                      ),
                      Positioned(
                        top: 227,
                        left: MediaQuery.of(context).size.width / 2 - 130,
                        child: GestureDetector(
                          onTap: selectedRole == null ? null : _handleNext,
                          child: _buildNextButton(selectedRole != null),
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
  }

  Widget _buildRoleCircle(
    String label, {
    double size = 160,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? const Color.fromARGB(255, 57, 56, 56)
                : Colors.grey.shade200,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),

                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildNextButton(bool enabled) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: 142,
    height: 142,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: enabled
          ? Colors.grey.shade300
          : const Color.fromARGB(255, 247, 242, 242),
      boxShadow: enabled
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ]
          : [],
    ),
    alignment: Alignment.center,
    child: Icon(
      Icons.arrow_forward,
      size: 36,
      color: enabled ? Colors.black87 : Colors.grey,
    ),
  );
}
