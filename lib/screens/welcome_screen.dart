import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:technostrelka_2025/theme/app_theme.dart';
import 'package:technostrelka_2025/widgets/next_button.dart';

import 'package:mesh_gradient/mesh_gradient.dart';

import 'package:flutter_svg/flutter_svg.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // var width = MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints.expand(),
          child: AnimatedMeshGradient(
            colors: AppTheme.gradientColors,
            options: AnimatedMeshGradientOptions(speed: 0.05),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 6, left: 4),
              child: SvgPicture.asset('assets/logos/tlm_logo.svg'),
            ),
          ),
        ),
        WellcomeText(),
        BuildWelcomeScreen(),
      ],
    );
  }
}

class WellcomeText extends StatelessWidget {
  const WellcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white, width: 8)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Image.asset(
              'assets/images/welcomeScreen/WellcomeText.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

class BuildWelcomeScreen extends StatelessWidget {
  const BuildWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 120, left: 40, right: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 32,
        children: [
          // Image.asset('assets/icons/App_Logo_400x400.png',
          //   width: 100,
          //   height: 100,
          //   fit: BoxFit.contain,
          // ),
          SizedBox(height: 320),
          // SimpleWelcomeText(), // Обычный текст, а не картинка
          NextButton(
            text: 'Начинаем',
            onPressed:
                () => {
                  context.go('/register'),
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => RegisterScreen())
                  //   )
                },
          ),
        ],
      ),
    );
  }
}

class SimpleWelcomeText extends StatelessWidget {
  const SimpleWelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Твое',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'время -',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'твои игра.',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
