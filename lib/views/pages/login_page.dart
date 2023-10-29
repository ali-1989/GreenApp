import 'package:app/structures/abstract/state_super.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/layout_page.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/widgets/custom_card.dart';

class LoginPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  LoginPage({super.key});

  @override
  State createState() => LoginPageState();
}
///=============================================================================
class LoginPageState extends StateSuper<LoginPage> {
  TextEditingController emailCtr = TextEditingController();
  TextEditingController passwordCtr = TextEditingController();
  late InputDecoration inputDecoration;
  bool showTextFieldError = false;


  @override
  void initState(){
    super.initState();

    const oBorder = OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.transparent)
    );

    inputDecoration = InputDecoration(
      fillColor: Colors.white,
      filled: true,
      enabledBorder: oBorder,
      focusedBorder: oBorder,
      errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppThemes.instance.currentTheme.errorColor)
      ),
    );
  }

  @override
  void dispose(){
    emailCtr.dispose();
    passwordCtr.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.loginBackG),
          fit: BoxFit.cover,
        )
      ),
      child: SizedBox.expand(
        child: ListView(
          children: [
            SizedBox(height: 40 * hRel),

            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                textDirection: TextDirection.ltr,
                children: [
                  Text(AppMessages.signIn.toUpperCase())
                      .color(Colors.white).fsRAdd(25)
                      .font(AppDecoration.gladioraBoldFont)
                  .bold(weight: FontWeight.w900),

                  const Text('GreenOasis',
                    style: TextStyle(shadows: [
                      Shadow(color: Colors.white, offset: Offset.zero, blurRadius: 1),
                      Shadow(color: Colors.white, offset: Offset.zero, blurRadius: 2),
                      Shadow(color: Colors.white, offset: Offset.zero, blurRadius: 3),
                      Shadow(color: Colors.white, offset: Offset(1, 2), blurRadius: 3),
                    ]),
                  ).fsRHole(2).bold()
                      .color(AppDecoration.mainColor)
                ],
              ),
            ),


            SizedBox(height: 60 * hRel),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0 * wRel),
              child: TextField(
                controller: emailCtr,
                decoration: inputDecoration.copyWith(
                  errorText: checkTextFieldErr(emailCtr),
                  hintText: AppMessages.email,
                  errorStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  )
                ),
              ),
            ),

            SizedBox(height: 10 * hRel),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0 * wRel),
              child: TextField(
                controller: passwordCtr,
                decoration: inputDecoration.copyWith(
                    errorText: checkTextFieldErr(passwordCtr),
                  hintText: AppMessages.password,
                    errorStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    )
                ),
              ),
            ),


            SizedBox(height: 12 * hRel),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0 * wRel),
              child: Row(
                children: [
                  Text(AppMessages.forgotPassword)
                      .color(Colors.white).bold(),

                  const SizedBox(width: 10),
                  CustomCard(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    radius: 6,
                    child: Text(AppMessages.passwordRecovery)
                    .bold().underLineClickable(),
                  )
                      //.color(Colors.blue),
                ],
              ),
            ),

            SizedBox(height: 25 * hRel),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0 * wRel),
              child: SizedBox(
                width: double.infinity,
                height: 30 * hRel,
                child: ElevatedButton(
                    onPressed: onLoginClick,
                    child: Text(AppMessages.signIn).fsRHole(2)
                ),
              ),
            ),

            SizedBox(height: 10 * hRel),
          ],
        ),
      ),
    );
  }

  String? checkTextFieldErr(TextEditingController ctr) {
    if(!showTextFieldError){
      return null;
    }

    return validateTextField(ctr);
  }

  String? validateTextField(TextEditingController ctr) {
    if(ctr == emailCtr){
      if(!Checker.isValidEmail(ctr.text.trim())){
        return AppMessages.emailIsNotCorrect;
      }
    }

    if(ctr == passwordCtr){
      if(ctr.text.trim().length < 4){
        return AppMessages.passwordMust4Char;
      }
    }

    return null;
  }

  void onLoginClick() {
    bool chk = validateTextField(emailCtr) == null;
    chk = chk && validateTextField(passwordCtr) == null;

    if(!chk){
      showTextFieldError = true;
    }
    else {
      showTextFieldError = true;
    }

    callState();

    if(!chk){
      return;
    }

    FocusHelper.hideKeyboardByService();
    RouteTools.pushPage(context, LayoutPage(key: AppBroadcast.layoutPageKey));
  }
}