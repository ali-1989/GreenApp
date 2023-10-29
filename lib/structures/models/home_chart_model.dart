
class HomeChartModel {
  String? countryName;

  HomeChartModel();

  HomeChartModel.fromMap(Map? map){
    if(map != null) {
      countryName = map['country_name'];
    }
  }

  Map<String, dynamic> toMap(){
    final ret = <String, dynamic>{};

    return ret;
  }
}
