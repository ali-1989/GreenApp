
enum ChartDimType {
  unKnow(0),
  day(1),
  week(2),
  month(3),
  year(4);

  final int _number;

  const ChartDimType(this._number);

  int serialize(){
    return _number;
  }

  factory ChartDimType.from(dynamic key){
    if(key is String){
      for(final i in ChartDimType.values){
        if(i.name == key){
          return i;
        }
      }
    }

    if(key is int){
      for(final i in ChartDimType.values){
        if(i._number == key){
          return i;
        }
      }
    }

    return ChartDimType.unKnow;
  }
}
