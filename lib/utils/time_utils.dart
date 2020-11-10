class TimeUtils {
  //获取儿童年龄 年 - 年
  static int getChildAge(String birthday) {
    if (birthday?.isEmpty ?? true) {
      return 0;
    }
    var babybirth = birthday.split('-');
    var now = new DateTime.now();
    return now.year - int.parse(babybirth[0]);
  }

  static String formatToDate(int time) {
    if(time < 10) {
      return "0$time";
    }
    return "$time";
  }

  static String getCurrentDate({String format = "-"}) {
    var now = new DateTime.now();
    return "${now.year}$format${now.month}$format${now.day}";
  }

  static String durationToTime(Duration duration, {bool showHour = false}) {
    int time = duration.inSeconds;
    int hour = duration.inHours;
    int min = duration.inMinutes;
    int second;
    if (hour > 0) {
      var hourStr = hour < 10 ? "0$hour" : hour.toString();
      var minStr = min < 10 ? "0$min" : min.toString();
      second = time % 3600 % 60;
      var secondStr = second < 10 ? "0$second" : second.toString();
      return "$hourStr:$minStr:$secondStr";
    } else if (min > 0) {
      var minStr = min < 10 ? "0$min" : min.toString();
      second = time % 60;
      var secondStr = second < 10 ? "0$second" : second.toString();
      if (showHour) {
        return "00:$minStr:$secondStr";
      } else {
        return "$minStr:$secondStr";
      }
    } else {
      var timeStr = time < 10 ? "0$time" : time.toString();
      if (showHour) {
        return "00:00:$timeStr";
      } else {
        return "00:$timeStr";
      }
    }
  }
}
