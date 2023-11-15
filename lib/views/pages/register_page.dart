import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/http_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/widgets/text/text_field_wrapper.dart';

class RegisterPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  RegisterPage({super.key});

  @override
  State createState() => RegisterPageState();
}
///=============================================================================
class RegisterPageState extends StateSuper<RegisterPage> {
  TextEditingController nameCtr = TextEditingController();
  TextEditingController familyCtr = TextEditingController();
  TextEditingController emailCtr = TextEditingController();
  TextEditingController passwordCtr = TextEditingController();
  TextEditingController rePasswordCtr = TextEditingController();
  bool showErrors = false;
  Requester requester = Requester();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameCtr.dispose();
    familyCtr.dispose();
    emailCtr.dispose();
    passwordCtr.dispose();
    rePasswordCtr.dispose();

    requester.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Row(
      children: [
        Flexible(
            flex: 8,
            child: buildFormSection()
        ),

        Flexible(
          flex: 2,
          child: Image.asset(AppImages.registerBackG,
            fit: BoxFit.fill,
            height: double.infinity,
            width: double.infinity,
          ),
        ),
      ],
    );
  }

  Widget buildFormSection() {
    return Column(
      children: [
        SizedBox(
          height: 60 * hRel,
        ),

        Image.asset(AppImages.icoSignUp, width: 120 * wRel, height: 50 * hRel),

        SizedBox(height: 25 * hRel),

        Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [

                      TextFieldWrapper(
                        messageBuilder: messageBuilder,
                        controller: nameCtr,
                        builder: (_, c, err) {
                          return TextField(
                            controller: nameCtr,
                            textInputAction: TextInputAction.next,
                            decoration: AppDecoration
                                .outlineBordersInputDecoration
                                .copyWith(
                              hintText: AppMessages.name,
                              errorStyle: const TextStyle(fontSize: -10),
                              errorText: err,
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 10 * hRel),
                      TextFieldWrapper(
                        messageBuilder: messageBuilder,
                        controller: familyCtr,
                        builder: (_, c, err) {
                          return TextField(
                            controller: familyCtr,
                            textInputAction: TextInputAction.next,
                            decoration: AppDecoration
                                .outlineBordersInputDecoration
                                .copyWith(
                              hintText: AppMessages.family,
                              errorStyle: const TextStyle(fontSize: -10),
                              errorText: err,
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 10 * hRel),
                      TextFieldWrapper(
                        messageBuilder: messageBuilder,
                        controller: emailCtr,
                        builder: (_, c, err) {
                          return TextField(
                            controller: emailCtr,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            decoration: AppDecoration
                                .outlineBordersInputDecoration
                                .copyWith(
                              hintText: AppMessages.email,
                              errorStyle: const TextStyle(fontSize: -10),
                              errorText: err,
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 10 * hRel),
                      TextFieldWrapper(
                          messageBuilder: messageBuilder,
                          controller: passwordCtr,
                          builder: (_, c, err) {
                            return TextField(
                                controller: passwordCtr,
                                textInputAction: TextInputAction.next,
                                decoration: AppDecoration
                                    .outlineBordersInputDecoration
                                    .copyWith(
                                  hintText: AppMessages.password,
                                  errorStyle: const TextStyle(fontSize: -10),
                                  errorText: err,
                                )
                            );
                          }
                      ),

                      SizedBox(height: 10 * hRel),
                      TextFieldWrapper(
                        messageBuilder: messageBuilder,
                        controller: rePasswordCtr,
                        builder: (_, c, err) {
                          return TextField(
                            controller: rePasswordCtr,
                            decoration: AppDecoration
                                .outlineBordersInputDecoration
                                .copyWith(
                              hintText: AppMessages.repeatPassword,
                              errorStyle: const TextStyle(fontSize: -10),
                              errorText: err,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40 * hRel),
                buildVerifyButton(),
                SizedBox(height: 20 * hRel),
              ],
            )
        ),
      ],
    );
  }

  Widget buildVerifyButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Transform.translate(
        offset: const Offset(-10, 0),
        child: ElevatedButton(
            onPressed: onVerifyClick,
            child: Text(AppMessages.verifyEmail.capitalizeFirstOfEach)
                .fsRRatio(3).englishRegularFont()
        ),
      ),
    );
  }

  Widget? messageBuilder(context, TextEditingController controller) {
    if (!showErrors) {
      return null;
    }

    String? msg;

    if (controller == nameCtr) {
      if (nameCtr.text
          .trim()
          .length < 2) {
        msg = AppMessages.nameMustBigger2Char;
      }
    }
    else if (controller == familyCtr) {
      if (familyCtr.text
          .trim()
          .length < 2) {
        msg = AppMessages.familyMustBigger2Char;
      }
    }
    else if (controller == emailCtr) {
      if (!Checker.isValidEmail(emailCtr.text.trim())) {
        msg = AppMessages.emailIsNotCorrect;
      }
    }
    else if (controller == passwordCtr) {
      if (passwordCtr.text
          .trim()
          .length < 4) {
        msg = AppMessages.passwordMust4Char;
      }
    }
    else if (controller == rePasswordCtr) {
      if (passwordCtr.text.trim() != rePasswordCtr.text.trim()) {
        msg = AppMessages.passwordsNotSame;
      }
    }

    if (msg == null) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Text(msg)
          .color(AppThemes.instance.currentTheme.errorColor)
          .fsRRatio(1),
    );
  }

  bool canVerifyInformation(TextEditingController controller) {
    if (controller == nameCtr) {
      if (nameCtr.text.trim().length < 2) {
        return false;
      }
    }
    else if (controller == familyCtr) {
      if (familyCtr.text.trim().length < 2) {
        return false;
      }
    }
    else if (controller == emailCtr) {
      if (!Checker.isValidEmail(emailCtr.text.trim())) {
        return false;
      }
    }
    else if (controller == passwordCtr) {
      if (passwordCtr.text.trim().length < 4) {
        return false;
      }
    }
    else if (controller == rePasswordCtr) {
      if (passwordCtr.text.trim() != rePasswordCtr.text.trim()) {
        return false;
      }
    }

    return true;
  }

  void onVerifyClick() {
    List<TextEditingController> cList = [
      nameCtr,
      familyCtr,
      emailCtr,
      passwordCtr,
      rePasswordCtr
    ];

    final can = cList.every((element) => canVerifyInformation(element));

    if (!can) {
      showErrors = true;
    }
    else {
      showErrors = false;
    }

    callState();

    if(!can){
      return;
    }

    FocusHelper.hideKeyboardByService();
    requestRegister();
  }

  void requestRegister(){
    showLoading();

    final js = <String, dynamic>{};
    js[Keys.request] = 'register_with_email';
    js['name'] = nameCtr.text.trim();
    js['family'] = familyCtr.text.trim();
    js['email'] = emailCtr.text.trim();
    js['password'] = Generator.generateMd5(passwordCtr.text.trim());

    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, res) async {
      bool handled = HttpTools.handler(context, req.getBodyAsJson()?? {});

      if(!handled) {
        AppSheet.showSheetOk(context, AppMessages.operationFailedTryAgain);
      }
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      AppSheet.showSheetOneAction(
          context,
          AppMessages.emailVerifyIsSentClickOn,
          onButton: (){
            RouteTools.pushPage(context, LoginPage());
          }
      );
    };

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request();
  }
}
