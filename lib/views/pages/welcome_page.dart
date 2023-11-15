
import 'package:app/services/google_sign_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/login_page.dart';
import 'package:app/views/pages/register_page.dart';
import 'package:app/views/sign_in/google_sign_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';

class WelcomePage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  WelcomePage({super.key});

  @override
  State createState() => WelcomePageState();
}
///=============================================================================
class WelcomePageState extends StateSuper<WelcomePage> {

  @override
  void initState(){
    super.initState();

    if(kIsWeb){
      GoogleSignService().signInSilently();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Material(
      child: Column(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppImages.welcomeBackG,
                width: ws,
                height: hs * 3/5.3,
                fit: BoxFit.cover,
              ),

              const Text('Welcome to ')
                  .fsRRatio(15)
                  .font(AppDecoration.gladioraLightFont)
                  .color(AppDecoration.mainColor),

              const Text('GreenOasis!')
                  .fsRRatio(15)
                  .font(AppDecoration.gladioraBoldFont)
                  .color(AppDecoration.mainColor)

            ],
          ),

          Expanded(
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  children: [
                   buildSocialLoginSection(),

                    /// google button
                   Builder(
                       builder: (_){
                         if(kIsWeb){
                           return buildSignInButton(onPressed: onGoogleClick);
                         }

                         return ElevatedButton(
                           style: ElevatedButton.styleFrom(
                             backgroundColor: ColorHelper.lightPlus(AppDecoration.buttonBackgroundColor(), val:0.2),
                           ),
                           onPressed: onGoogleClick,
                           child: Image.asset(AppImages.icoGoogle, width: 32*iconR, height: 32*iconR),
                         );
                       }
                   ),


                    /// login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onSignInClick,
                        child: Text(AppMessages.signIn.capitalizeFirstOfEach)
                            .bold(weight: FontWeight.w900).fsR(3),
                      ),
                    ),

                    /// signUp button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onSignUpClick,
                        child: Text(AppMessages.signUp.capitalizeFirstOfEach)
                            .bold(weight: FontWeight.w900).fsR(3),
                      ),
                    ),
                  ],
                ),
              )
          )
        ],
      ),
    );
  }

  Widget buildSocialLoginSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: ws/4,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorHelper.lightPlus(AppDecoration.buttonBackgroundColor(), val:0.2),
            ),
              onPressed: onFaceBookClick,
              child: buildIcon(AppImages.icoFaceBook),
          ),
        ),

        SizedBox(
          width: ws/4,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorHelper.lightPlus(AppDecoration.buttonBackgroundColor(), val:0.2),
            ),
            onPressed: onLinkedInClick,
            child: buildIcon(AppImages.icoLinkedIn),
          ),
        ),

        SizedBox(
          width: ws/4,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorHelper.lightPlus(AppDecoration.buttonBackgroundColor(), val:0.2),
            ),
            onPressed: onMetaClick,
            child: buildIcon(AppImages.icoX),
          ),
        ),
      ],
    );
  }

  Widget buildIcon(String assets){
    return Image.asset(assets, width: 20*iconR, height: 20*iconR, fit: BoxFit.fill);
  }

  void onFaceBookClick() {
  }

  Future<void> onGoogleClick() async {
    showLoading();
    final res = await GoogleSignService().signIn();
    hideLoading();
    final x = await GoogleSignService().getCredentialInfo();
  }

  void onLinkedInClick() async {
    //await GoogleSignService().signOut();
    /*showLoading();
    final res = await GithubSignService().signIn();
    print('************user: ${GithubSignService().currentAuthUser?.photoURL}');
    print('********* ${res.$1?.user?.email}');
    print('********* ${res.$1?.user?.displayName}');
    print('********* ${res.$1?.user?.photoURL}');

    hideLoading();*/
  }

  void onMetaClick() async {
    //RouteTools.pushPage(context, SignInDemo());
  }

  void onSignUpClick() {
    RouteTools.pushPage(context, RegisterPage());
  }

  void onSignInClick() {
    RouteTools.pushPage(context, LoginPage());
  }
}