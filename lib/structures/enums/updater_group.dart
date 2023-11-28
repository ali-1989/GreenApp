import 'package:iris_tools/modules/stateManagers/updater_state.dart';

enum UpdaterGroup implements UpdaterGroupId {
  greenMindUpdate(100),
  greenClientUpdate(101);

  final int _number;

  const UpdaterGroup(this._number);

  int serialize(){
    return _number;
  }
}
