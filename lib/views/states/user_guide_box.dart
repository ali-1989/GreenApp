import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/widgets/custom_card.dart';

class UserGuideBox extends StatelessWidget {
  final String message;
  const UserGuideBox({super.key, required this.message}) : super();

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: AppDecoration.buttonBackgroundColor().withAlpha(230),
      border: Border.all(color: AppDecoration.buttonBackgroundColor(), width: 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(height: 1.4))
                .color(Colors.white).fsRRatio(2).bold(),

            /*SizedBox(height: 14 * hRel),

                  TextButton(
                      onPressed: onHideAddWidgetGuid,
                      child: Text(AppMessages.iRealized)
                          .bold().color(AppDecoration.buttonBackgroundColor()).fsR(2)
                  )*/
          ],
        ),
      ),
    );
  }
}
