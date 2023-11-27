
enum ClientType {
  unKnow(0),
  temperature(1),
  humidity(2),
  light(3),
  soil(4),
  volume(5);

  final int _number;

  const ClientType(this._number);

  int serialize(){
    return _number;
  }

  factory ClientType.from(dynamic key){
    if(key is String){
      for(final i in ClientType.values){
        if(i.name == key){
          return i;
        }
      }
    }

    if(key is int){
      for(final i in ClientType.values){
        if(i._number == key){
          return i;
        }
      }
    }

    return ClientType.unKnow;
  }
}
