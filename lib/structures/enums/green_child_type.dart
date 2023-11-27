
enum GreenChildType {
  unKnow(0),
  sight(1),
  guide(2);

  final int _number;

  const GreenChildType(this._number);

  int serialize(){
    return _number;
  }

  factory GreenChildType.from(dynamic key){
    if(key is String){
      for(final i in GreenChildType.values){
        if(i.name == key){
          return i;
        }
      }
    }

    if(key is int){
      for(final i in GreenChildType.values){
        if(i._number == key){
          return i;
        }
      }
    }

    return GreenChildType.unKnow;
  }
}
