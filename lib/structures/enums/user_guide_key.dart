
enum UserGuideKey {
  unKnow(0),
  homePageAddWidget(1);

  final int _number;

  const UserGuideKey(this._number);

  int serialize(){
    return _number;
  }

  factory UserGuideKey.from(dynamic key){
    if(key is String){
      for(final i in UserGuideKey.values){
        if(i.name == key){
          return i;
        }
      }
    }

    if(key is int){
      for(final i in UserGuideKey.values){
        if(i._number == key){
          return i;
        }
      }
    }

    return UserGuideKey.unKnow;
  }
}
