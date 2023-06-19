import 'dart:convert';
import 'dart:html';
import 'Actor.dart';
import 'Doctor.dart';
import 'dart:math';

class Field {
  late double width,
      height,
      baseSpeed = 4.8,
      playerSpeed = 5,
      length = 0,
      distance = 0;
  late bool finished = false,
      levelEnd = false,
      inPosition = false,
      nearlyFinished = false,
      started = false,
      gameOver = false;
  late int level, score = 0;
  var config, storage;
  late List<dynamic> mask = [],
      syringe = [],
      barricade = [],
      deadlyvirus = [],
      virus = [],
      drain = [],
      car = [],
      actors = [];
  dynamic street;
  late Doctor doctor;
  Actor? killer;

  Field() {
    HttpRequest.getString('Levels.json').then((myjson) {
      storage = window.localStorage;
      config = jsonDecode(myjson);
      final levels = jsonDecode(storage['levels'] ?? '[]');
      if (storage.isEmpty) {
        for (var elem in config) {
          var lvl = elem['Level'][0];
          var svl = elem['Level'][1];
          var seen = elem['Level'][2];
          levels.add({'level': '$lvl', 'solved': '$svl', 'seen': '$seen'});
        }
        storage['levels'] = jsonEncode(levels);
      }
    });
  }
  void setDoctor(Doctor doc) {
    doctor = doc;
  }

  void moveStreet() {
    street.move(baseSpeed);
  }

  void moveDoctor() {
    doctor.move();
  }

  /* Setzt ob der Doctor nach Rechts oder nach Links läuft */
  void docSetLeft(bool left) => doctor.setLeft(left);
  void docSetRight(bool right) => doctor.setRight(right);

  void moveEnemy() {
    actors.forEach((element) {
      element.move();
    });
  }

  void updateScore(int points) {
    score += points;
  }

  bool detectLevelEnd() {
    if (distance >= length - 150) nearlyFinished = true;
    if (distance >= length) return true;
    return false;
  }

  void collision_with(Actor actor) {
    killer = actor;
  }

  bool getLevelEnd() => levelEnd;
  void setLevelEnd() => levelEnd = true;
  void setFinished() => finished = true;
  void setinPosition() => inPosition = true;
  void setLevel(int lvl) => level = lvl;

  void updateDistance(double distance) {
    this.distance = this.distance + distance;
  }

  /*Generiert zufällige Nummer um den Enemy auf der xAchse zu spawnen 
  ohne Überlappung mit dem zu letzt gespawnten Gegner*/
  int generateRandomNumber(int size) {
    var random = Random().nextInt(width.toInt() - size.toInt());
    if (actors.length > 1) {
      while (!(random > actors.last.xPos + size ||
          random < actors.last.xPos - size)) {
        random = Random().nextInt(width.toInt() - size.toInt());
      }
    }
    return random;
  }

  /*Generiert zufällig A oder B */
  /*Für Enemys die entweder auf der einen Seite oder der anderen Seite spawnen */
  double generateRandomNumberAorB(var size, double a, double b) {
    var random = Random().nextInt(2).toDouble();
    if (random == 0) {
      random = a * width;
    } else {
      random = b * width - size;
    }
    return random;
  }

  void reCalculatePoints() {
    score += doctor.syringeScore * 50 + doctor.maskScore * 20;
  }

  void setSpeed(double speed) {}

  void resetLevel() {
    distance = 0;
    levelEnd = false;
    inPosition = false;
    finished = false;
    nearlyFinished = false;
    actors = [];
    score = 0;
  }

  void levelFinished() {
    if (level < config.length) {
      final levels = jsonDecode(storage['levels'] ?? '[]');
      levels[level]['solved'] = 'true';
      storage['levels'] = jsonEncode(levels);
    }
  }

  List<List> toGenerate(var time) {
    var result = <List>[];
    if (virus.isNotEmpty) {
      if (time % virus[0] == 0) {
        result.add(List.from(List.from(['virus', virus[1], 0])));
      }
    }
    if (deadlyvirus.isNotEmpty) {
      if (time % deadlyvirus[0] == 0) {
        result.add(List.from(['deadlyvirus', deadlyvirus[1], deadlyvirus[2]]));
      }
    }
    if (drain.isNotEmpty) {
      if (time % drain[0] == 0) {
        result.add(List.from(['drain', drain[1], 0]));
      }
    }
    if (car.isNotEmpty) {
      if (time % car[0] == 0) {
        result.add(List.from(['car', car[1], 0]));
      }
    }
    if (barricade.isNotEmpty) {
      if (time % barricade[0] == 0) {
        result.add(List.from(['barricade', barricade[1], 0]));
      }
    }
    if (syringe.isNotEmpty) {
      if (time % syringe[0] == 0) {
        result.add(List.from(List.from(['syringe', syringe[1], 0])));
      }
    }
    if (mask.isNotEmpty) {
      if (time % mask[0] == 0) {
        result.add(List.from(List.from(['mask', mask[1], 0])));
      }
    }
    return result;
  }

  void loadLevel(var json) {
    length = json['length'];
    level = json['Level'][0];
    baseSpeed = json['BaseSpeed'];
    playerSpeed = json['PlayerSpeed'];
    if (json['car'] != null) {
      car = List.from([json['car'][0], json['car'][1]]);
    } else {
      car = [];
    }
    if (json['drain'] != null) {
      drain = List.from([json['drain'][0], json['drain'][1]]);
    } else {
      drain = [];
    }
    if (json['virus'] != null) {
      virus = List.from([json['virus'][0], json['virus'][1]]);
    } else {
      virus = [];
    }
    if (json['deadlyvirus'] != null) {
      deadlyvirus = List.from([
        json['deadlyvirus'][0],
        json['deadlyvirus'][1],
        json['deadlyvirus'][2]
      ]);
    } else {
      deadlyvirus = [];
    }
    if (json['barricade'] != null) {
      barricade = List.from([json['barricade'][0], json['barricade'][1]]);
    } else {
      barricade = [];
    }
    if (json['syringe'] != null) {
      syringe = List.from([json['syringe'][0], json['syringe'][1]]);
    } else {
      syringe = [];
    }
    if (json['mask'] != null) {
      mask = List.from([json['mask'][0], json['mask'][1]]);
    } else {
      mask = [];
    }
  }
}
