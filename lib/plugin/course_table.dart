import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Eamis {
  static Eamis instance;
  SharedPreferences prefs;

  factory Eamis() {
    if (instance == null) {
      instance = Eamis._init();
    }
    return instance;
  }

  clear() {
    cookieJar.deleteAll();
    instance = null;
    prefs.remove("course_table");
  }

  Eamis._init() {
    dio.interceptors.add(CookieManager(cookieJar));
    dio.options.headers = headers;
//    dio.options.receiveTimeout = 10000;
//    dio.options.connectTimeout = 10000;
    SharedPreferences.getInstance().then((value) {
      prefs = value;
    });
  }

  bool ok = false;

  Future<void> run() async {
    try {
      if (!ok) {
        await init();
        ok = true;
        save();
      }
    } on Error catch (e) {
      print(e);
      e.stackTrace;
      ok = false;
    } on Exception catch (e) {
      print(e);
      ok = false;
    }
  }

  Map<int, List<Lesson>> course = {
    1: null,
    2: null,
    3: null,
    4: null,
    5: null,
    6: null,
    7: null,
    0: null
  };

  Map<String, String> headers = const {
    "Accept":
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3",
    "Accept-Encoding": "gzip, deflate",
    "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
    "Cache-Control": "no-cache",
    "Connection": "keep-alive",
    "Host": "eamis.nankai.edu.cn",
    "Pragma": "no-cache",
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
  };
  Dio dio = Dio();
  String loginUrl = "http://eamis.nankai.edu.cn/eams/login.action";
  String reqUrl = "http://eamis.nankai.edu.cn/eams/myPlanCompl.action?_=";
  String courseUrl =
      "http://eamis.nankai.edu.cn/eams/courseTableForStd!courseTable.action";
  Uri uri = Uri.parse("http://eamis.nankai.edu.cn/eams");
  DefaultCookieJar cookieJar = CookieJar();
  String username;
  String password;
  String nowSemesterId = "4083";
  int unitCount;
  static RegExp idsExp =
      RegExp("bg.form.addInput\\(form,\"ids\",\"(\\d*)\"\\);");
  String ids;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    load();
    if (password == null || username == null) return;
    if (ok) return;
    await login();
    await getTermSelector();
    String data = await getSchedule();
    var parser = NKUCourseParser(data, course);
    unitCount = parser.unitCount;
  }

  void save() {
    Map<String, dynamic> courseJson = {};
    course.forEach((key, value) {
      courseJson[key.toString()] = List<Map<String, dynamic>>.generate(
          value.length, (i) => value[i]?.toJson());
    });
    prefs.setString(
        "course_table",
        json.encode({
          "username": username,
          "password": password,
          "course": courseJson,
          "unitCount": unitCount,
          "ids": ids,
          "ok": ok
        }));
  }

  void load() {
    if (prefs == null) return;
    var data = prefs.getString("course_table");
    if (data == null) return;
    var loadData = json.decode(data);
    username = loadData["username"];
    password = loadData["password"];
    course = {};
    loadData["course"].forEach((key, value) {
      course[int.parse(key)] = List<Lesson>.generate(value.length,
          (i) => value[i] == null ? null : Lesson.fromJson(value[i]));
    });
    unitCount = loadData["unitCount"];
    ids = loadData["ids"];
    ok = loadData['ok'];
  }

  Future<void> login() async {
    Map<String, String> data = {
      "username": username,
      "password": password,
      "encodedPassword": "",
      "session_locale": "zh_CN"
    };
    // print(cookieJar.loadForRequest(uri));
    Response req = await dio.post(loginUrl,
        data: data,
        options: Options(
            contentType: "application/x-www-form-urlencoded",
            followRedirects: false,
            validateStatus: (status) {
              return status < 400;
            }));
    try {
      cookieJar.saveFromResponse(
          uri, [Cookie.fromSetCookieValue(req.headers['set-cookie'][0])]);
    } on NoSuchMethodError catch (e) {
      print(e);
    }
  }

  Future<void> getTermSelector() async {
    RegExp exp = new RegExp(r"(?<=toolbar)\d+");
    RegExp exp2 = new RegExp(r"(?<=#semesterBar)\d+");
    String firstUrl =
        "http://eamis.nankai.edu.cn/eams/courseTableForStd.action?_=${DateTime.now().millisecondsSinceEpoch}";
    Response res = await dio.get(firstUrl);
    var id = exp.firstMatch(res.data)?.group(0);
    if (id == null) {
      id = exp2.firstMatch(res.data)?.group(0);
    }
    ids = idsExp.firstMatch(res.data).group(1);
    String query = 'http://eamis.nankai.edu.cn/eams/dataQuery.action';

    Map<String, String> data = {
      "tagId": "semesterBar${id}Semester",
      "dataType": "semesterCalendar",
      "value": nowSemesterId,
      "empty": "false"
    };
    // print(cookieJar.loadForRequest(uri));
    Response req = await dio.post(query,
        data: data,
        options: Options(
            contentType: "application/x-www-form-urlencoded",
            followRedirects: false,
            validateStatus: (status) {
              return status < 400;
            }));
    // print(req.headers);
    // print(req.request.headers);
    // print(req.data);
  }

  Future<void> getGrade() async {
    var req = await dio.get("$reqUrl${DateTime.now().millisecondsSinceEpoch}");
    // print(req.data);
    return req.data;
  }

  Future<String> getSchedule() async {
    Map<String, String> data = {
      "ignoreHead": "1",
      "setting.kind": "std",
      "startWeek": "",
      "semester.id": nowSemesterId,
      "ids": ids
    };

    // print(cookieJar.loadForRequest(uri));
    Response req = await dio.post(courseUrl,
        data: data,
        options: Options(
            contentType: "application/x-www-form-urlencoded",
            followRedirects: false,
            validateStatus: (status) {
              return status < 400;
            }));
    return req.data;
  }
}

class Lesson {
  Lesson(this.course, this.day, this.index);

  Course course;
  int day;
  int index;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(Course.fromJson(json['course']), json['day'], json['index']);
  }

  Map<String, dynamic> toJson() {
    return {"course": course.toJson(), "day": day, "index": index};
  }

  @override
  String toString() {
    return "Lesson: ${course.name}";
  }
}

class Course {
  static Map<String, Course> courses = {};

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
        name: json["name"],
        teacher: json['teacher'],
        courseId: json['courseId'],
        position: json['postion'],
        validWeeks: List<bool>.generate(
            json['validWeeks'].length, (i) => json['validWeeks'][i]));
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "teacher": teacher,
      "courseId": courseId,
      "postion": position,
      "validWeeks": validWeeks
    };
  }

  factory Course(
      {String name,
      String teacher,
      int courseId,
      String position,
      List<bool> validWeeks}) {
    Course course;
    var key = "$courseId-$position";
    if (courses.containsKey(key)) {
      course = courses[key];
      if (position == "停课") {
        for (int i = 0; i < (validWeeks?.length ?? 0); i++) {
          if (validWeeks[i]) {
            course.validWeeks[i] = false;
          }
        }
      } else {
        course.position = position;
        for (int i = 0; i < (validWeeks?.length ?? 0); i++) {
          if (validWeeks[i]) {
            course.validWeeks[i] = true;
          }
        }
      }
    } else {
      course = Course._init(
          name: name,
          teacher: teacher,
          courseId: courseId,
          position: position,
          validWeeks: validWeeks ?? []);
      courses[key] = course;
    }
    return course;
  }

  Course._init(
      {this.name, this.teacher, this.courseId, this.position, this.validWeeks});

  String name;
  String teacher;
  int courseId;
  String position;
  List<bool> validWeeks;

  @override
  String toString() {
    return "Course: $name";
  }

//  @override
//  int get hashCode {
//    return courseId;
//  }
//
//  @override
//  bool operator ==(other) {
//    return other.runtimeType == runtimeType && (other as Course).courseId == courseId;
//  }

}

class NKUCourseParser {
  NKUCourseParser(this.data, this.courses) {
    parseCourse();
  }

  static RegExp lines =
      RegExp("var teachers(.|\\s)*?(?=(var teacher)|(table0.marshalTable))");
  static RegExp courseInfo = RegExp(
      "activity = new TaskActivity\\(actTeacherId.join\\(','\\),actTeacherName.join\\(','\\),\"(\\d*\\((\\d*)\\))\",\"(.*)\",\"(-?\\d*)\",\"(.*?)\",\"(\\d*)\"");
  static RegExp unitCountReg = RegExp("(?<=var unitCount = )\\d*");
  static RegExp teacher =
      RegExp("var teachers = \\[{id:\\d*,name:\"(.*?)\",lab:false}\\];");
  static RegExp courseTime = RegExp("index =(\\d)\\*unitCount\\+(\\d+);");
  String data;
  var _coursesBlock;
  Map<int, List<Lesson>> courses;
  int unitCount;

  parseCourse() {
    _coursesBlock = lines.allMatches(data);
    unitCount = int.parse(unitCountReg.firstMatch(data).group(0));
    for (int i = 1; i <= 7; i++) {
      courses[i] = List.generate(unitCount, (e) => null);
    }
    courses[0] = List.generate(
        unitCount,
        (e) => Lesson(
            Course(name: (e + 1).toString(), position: "", courseId: -e),
            null,
            e));
    _coursesBlock.forEach((e) {
      parseSingleCourse(e.group(0));
    });
  }

  void parseSingleCourse(String course) {
    var info = courseInfo.firstMatch(course);
    int id = int.parse(info.group(2));
    String courseName = info.group(3);
    courseName =
        courseName.substring(0, courseName.length - info.group(2).length - 2);
    String position = info.group(5);
    String weeks = info.group(6);
    List<bool> validWeeks =
        List<bool>.generate(weeks.length, (e) => weeks.codeUnitAt(e) == 49);
    var teacherName = teacher.firstMatch(course).group(1);
    var time = courseTime.allMatches(course);
    var cour = Course(
      courseId: id,
      name: courseName,
      teacher: teacherName,
      position: position,
      validWeeks: validWeeks,
    );
    List<Lesson> times = List<Lesson>.generate(
        time.length,
        (e) => Lesson(cour, int.parse(time.elementAt(e).group(1)) + 1,
            int.parse(time.elementAt(e).group(2)) + 1));
    times.forEach((e) {
      courses[e.day][e.index - 1] = e;
    });
  }
}
