import 'package:app/structures/enums/user_guide_key.dart';

class UserGuideModel {
  late UserGuideKey key;
  int guideShowCount = 0;

  UserGuideModel();

  UserGuideModel.fromMap(Map map){
    key = UserGuideKey.from(map['key']);
    guideShowCount = map['guideShowCount']?? 0;
  }

  Map<String, dynamic> toMap(){
    final ret = <String, dynamic>{};
    ret['key'] = key.serialize();
    ret['guideShowCount'] = guideShowCount;

    return ret;
  }

  bool isGuided(){
    return guideShowCount > 0;
  }
}
