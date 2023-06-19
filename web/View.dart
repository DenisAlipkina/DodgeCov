import 'dart:convert';
import 'dart:html';
import 'dart:math';
import 'Barricade.dart';
import 'Car.dart';
import 'Doctor.dart';
import 'Drain.dart';
import 'Field.dart';
import 'DeadlyVirus.dart';
import 'Hospital.dart';
import 'Mask.dart';
import 'Street.dart';
import 'Syringe.dart';
import 'Virus.dart';

class View {
  late bool collectedSyringe = false, collectedMask = false;
  late List<Element> enemys = [];
  late Element street;
  List<String> shownTutorialForLevels = [];
  Field model;
  var doctor;

  View(this.model);

  /* Erstellt das Hauptmenü */
  void initialise() {
    document.getElementById('view-container')?.innerHtml =
        "<div class='menu-container'><h1>DodgeCov21</h1><img src='res/Spritze.png'/><br><br><button id='level-select-button' class='button'>Level Selection</button><br><br><p>Denis Alipkina & Tobias Konrad & Tim Lüneburg</p></div>";
  }

  /* Generiert Gegner */
  void generateEnemy(var klasse, var ySpeed, var xSpeed) {
    var string;
    if (klasse == 'drain') {
      string = '<div class=' '$klasse' '><div class="drain-top"></div></div>';
    } else {
      string = '<div class=' '$klasse' '></div>';
    }
    document.getElementById('game-field')?.appendHtml(string);
    var height = (querySelector('.$klasse')?.getBoundingClientRect()?.height ??
        0.0) as double;
    var width = (querySelector('.$klasse')?.getBoundingClientRect()?.width ??
        0.0) as double;
    var random;
    if (klasse == 'drain' || klasse == 'barricade') {
      random = model.generateRandomNumberAorB(width, 0.22, 0.78);
    } else if (klasse == 'car') {
      random = model.generateRandomNumberAorB(width, 0.31, 0.69);
    } else {
      if (klasse != 'hospital') {
        random = model.generateRandomNumber(width as int);
      }
    }
    var enemy;
    switch (klasse) {
      case ('virus'):
        enemy = Virus(model, random, -height, ySpeed);
        break;
      case ('deadlyvirus'):
        enemy = DeadlyVirus(model, random, -height, ySpeed);
        enemy.xSpeedReduction = xSpeed;
        break;
      case ('drain'):
        enemy = Drain(model, random, -height, ySpeed);
        if (!(0.22 * model.width == random)) {
          querySelector('.drain:last-child')?.children.first.style.left =
              '-30px';
        }
        break;
      case ('car'):
        enemy = Car(model, random, -height * 2, ySpeed);
        var randomCar = Random().nextInt(3);
        if (randomCar == 0) {
          querySelector('.car:last-child')?.style.backgroundImage =
              'url("res/Car_Blue.png")';
        } else if (randomCar == 1) {
          querySelector('.car:last-child')?.style.backgroundImage =
              'url("res/Car_Red.png")';
        } else {
          querySelector('.car:last-child')?.style.backgroundImage =
              'url("res/Car_Yellow.png")';
        }
        break;
      case ('barricade'):
        enemy = Barricade(model, random, -height, ySpeed);
        break;
      case ('syringe'):
        enemy = Syringe(model, random, -height, ySpeed);
        break;
      case ('mask'):
        enemy = Mask(model, random, -height, ySpeed);
        break;
      case ('hospital'):
        enemy = Hospital(model, 0, -height, ySpeed);
        break;
    }
    string = '.$klasse:last-child';
    enemy
        .setWidth(querySelector(string)?.getBoundingClientRect()?.width ?? 0.0);
    enemy.setHeigth(
        querySelector(string)?.getBoundingClientRect()?.height ?? 0.0);
    model.actors.add(enemy);
    enemys.add(querySelector(string)!);
  }

  /* Zeigt die Levelübersicht an */
  void goToLevels() {
    final levels = jsonDecode(model.storage['levels'] ?? '[]');
    var html = [];
    html.add("<div class='menu-container'><h1>Level Selection</h1>");
    for (var i = 1; i <= levels.length; i++) {
      if (levels[i - 1]['solved'] == 'true') {
        html.add(
            "<br><br><button id='level$i' class='button'>Level $i</button>");
      } else {
        html.add(
            "<br><br><button id='level$i' class='button' disabled>Level $i</button>");
      }
    }
    html.add(
        "<br><br><button id='zurueck' class='cancel-button'>Back</button></div>");
    document.getElementById('view-container')?.innerHtml = html.join();
  }

  /* Zeigt das Spielfeld an */
  void startGame() {
    document.getElementById('view-container')?.innerHtml =
        "<div id='street-container'><div class='street'></div><div class='street'></div></div><div id='game-field'><div class='board' id='score'><span id='gameScore'>00000</span><span id='plus-syringe'>+20</span><span id='plus-mask'>+10</span></div><div class='board' id='items'><div class='syringe-box'><div class='syringe-image'></div><div id='syringe-counter'><span id='syringe-count'>0</span></div></div><div class='mask-box'><div class='mask-image'></div><div id='mask-counter'><span id='mask-count'>0</span></div></div></div><div id='player'></div></div>";

    street = querySelector('.street')!;
    model.street = (Street(
        model,
        -(querySelector('#street-container')?.getBoundingClientRect()?.height ??
            0.0) as double));
    doctor = querySelector('#player');
    model.width =
        (querySelector('#street-container')?.getBoundingClientRect()?.width ??
            0.0) as double;
    model.height =
        (querySelector('#street-container')?.getBoundingClientRect()?.height ??
            0.0) as double;
  }

  /* Zeigt den LevelEnde Screen an */
  void gameEnd() {
    querySelector('#player')?.style.animationPlayState = 'paused';
    document.getElementById('gameover-Screen')?.style?.display = 'block';
    querySelector('#gameover-header')?.text = 'Game Over';
    if (model.killer is Hospital) {
      querySelector('#gameover-header')?.text = 'Hospital reached';
      if (!(model.config.length == model.level)) {
        document.getElementById('gameover-Screen-content')?.appendHtml(
            '<div id="gameover-content"><img src="res/GameWon.png" width="400" height="235"> <br><br><span>Points: ${model.score}</span><br><br><button class="button">Next Level</button> <br><br><button class="button">Menu</button></div>');
      } else {
        document.getElementById('gameover-Screen-content')?.appendHtml(
            '<div id="gameover-content"><img src="res/GameWon.png" width="400" height="235"> <br><br><span>Points: ${model.score}</span><br><br><button class="button">Menu</button></div>');
      }
    } else if (model.killer is Virus) {
      document.getElementById('gameover-Screen-content')?.appendHtml(
          '<div id="gameover-content"><img src="res/Gameover_Virus.png" width="400" height="235"> <br><br><span>Points: ${model.score}</span><br><br><button class="button">Restart</button> <br><br><button class="button">Menu</button></div>');
    } else if (model.killer is DeadlyVirus) {
      document.getElementById('gameover-Screen-content')?.appendHtml(
          '<div id="gameover-content"><img src="res/Gameover_Virus.png" width="400" height="235"> <br><br><span>Points: ${model.score}</span><br><br><button class="button">Restart</button> <br><br><button class="button">Menu</button></div>');
    } else if (model.killer is Drain) {
      document.getElementById('gameover-Screen-content')?.appendHtml(
          '<div id="gameover-content"><img src="res/Gameover_Drain.png" width="400" height="235"><br><br><span>Points: ${model.score}</span><br><br><button class="button">Restart</button> <br><br><button class="button">Menu</button></div>');
    } else if (model.killer is Car) {
      document.getElementById('gameover-Screen-content')?.appendHtml(
          '<div id="gameover-content"><img src="res/Gameover_Car.png" width="400" height="235"><br><br><span>Points: ${model.score}</span><br><br><button class="button">Restart</button> <br><br><button class="button">Menu</button></div>');
    } else if (model.killer is Barricade) {
      document.getElementById('gameover-Screen-content')?.appendHtml(
          '<div id="gameover-content"><img src="res/Gameover_Barricade.png" width="400" height="235"><br><br><span>Points: ${model.score}</span><br><br><button class="button">Restart</button> <br><br><button class="button">Menu</button></div>');
    }
  }

  /* Lässt den Player springen */
  void playerJump() {
    querySelector('#player')?.style.animation = 'jump 0.75s';
  }

  /* Lässt den Player laufen */
  void playerRun() {
    querySelector('#player')?.style.animation = 'run 1.2s infinite';
  }

  /* Wählt aus was angezeigt werden soll */
  void goTo(String text) {
    switch (text) {
      case 'Level Selection':
        {
          goToLevels();
          reset();
        }
        break;
      case 'Start':
        {
          startGame();
          var doc = Doctor(model, 300, 0, 7);
          doc.setWidth(
              (querySelector('#player')?.getBoundingClientRect()?.width ?? 0.0)
                  as double);
          doc.setHeigth(
              (querySelector('#player')?.getBoundingClientRect()?.height ?? 0.0)
                  as double);
          model.setDoctor(doc);
          var margin_bottom = model.height - model.doctor.width - 30;
          model.doctor.yPos = margin_bottom;
          doctor.style?.top = '${model.doctor.yPos.toInt()}px';
        }
        break;
      case 'Restart':
        {
          reset();
          goTo('Start');
        }
        break;
      case 'Back':
        {
          initialise();
        }
        break;
      case 'Menu':
        {
          reset();
          initialise();
        }
        break;
      case 'Continue':
        {
          start();
        }
    }
  }

  void start() {
    document.getElementById('gameover-content')?.remove();
    querySelector('#player')?.style.animationPlayState = 'paused';
    document.getElementById('gameover-Screen')?.style?.display = 'none';
  }

  void pause() {
    querySelector('#player')?.style.animationPlayState = 'paused';
    document.getElementById('gameover-Screen')?.style?.display = 'block';
    querySelector('#gameover-header')?.text = 'Paused';
    document.getElementById('gameover-Screen-content')?.appendHtml(
        '<div id="gameover-content"><img src="res/Pause.png" width="200" height="200"><br><br><br><button class="button">Continue</button><br><br><button class="button">Level Selection</button> <br><br><button class="button">Menu</button></div>');
  }

  void reset() {
    document.getElementById('gameover-content')?.remove();
    document.getElementById('gameover-Screen')?.style?.display = 'none';
    enemys = [];
    model.resetLevel();
  }

  void updateItems(int syringe, int mask) {
    document.getElementById('syringe-count')?.remove();
    document.getElementById('mask-count')?.remove();
    document.getElementById('syringe-counter')?.appendHtml(
        '<span id="syringe-count">' '${model.doctor.syringeScore}' '</span>');
    document.getElementById('mask-counter')?.appendHtml(
        '<span id="mask-count">' '${model.doctor.maskScore}' '</span>');
  }

  void updateScore() {
    var nulls = 5 - model.score.toString().length;
    var score_string = '0' * nulls + model.score.toString();
    document.getElementById('gameScore')?.remove();
    document
        .getElementById('score')
        ?.appendHtml('<span id="gameScore">' '$score_string' '</span>');
  }

  void usingSyringe() {
    querySelector('#player')?.style?.backgroundColor =
        'rgba(90, 255, 255, 0.55)';
    querySelector('#player')?.style?.boxShadow =
        'rgba(0, 0, 0, 0.55) 0px 54px 55px, rgba(90, 255, 255, 0.42) 0px -12px 30px, rgba(90, 255, 255, 0.42) 0px 4px 6px, rgba(90, 255, 255, 0.47) 0px 12px 13px, rgba(90, 255, 255, 0.39) 0px -3px 5px';
  }

  void notusingItem() {
    querySelector('#player')?.style?.backgroundColor = 'rgba(200, 200, 0, 0)';
    querySelector('#player')?.style?.boxShadow = 'none';
  }

  void usingMask() {
    querySelector('#player')?.style?.backgroundColor =
        'rgba(200, 200, 0, 0.55)';
    querySelector('#player')?.style?.boxShadow =
        'rgba(0, 0, 0, 0.55) 0px 54px 55px, rgba(200, 200, 0, 0.42) 0px -12px 30px, rgba(200, 200, 0, 0.42) 0px 4px 6px, rgba(200, 200, 0, 0.47) 0px 12px 13px, rgba(200, 200, 0, 0.39) 0px -3px 5px';
  }

  void showPlusPoints(var item) {
    if (item == 'syringe') {
      querySelector('#plus-syringe')?.style?.opacity = '1';
    } else if (item == 'mask') {
      querySelector('#plus-mask')?.style?.opacity = '1';
    }
  }

  void hidePlusPoints(var item) {
    if (item == 'syringe') {
      querySelector('#plus-syringe')?.style?.opacity = '0';
    } else if (item == 'mask') {
      querySelector('#plus-mask')?.style?.opacity = '0';
    }
  }

  bool handleTutorials(var level_index) {
    var html = [];
    final levels = jsonDecode(model.storage['levels'] ?? '[]');
    if (levels[level_index]['seen'] == 'true') {
      if (level_index == 0) {
        html.add(
            "<div class='menu-container'><div class='info-box'><img src='res/HowToBasic.png'></img><br><br><button class='button'>Start</button><br><br><button class='cancel-button'>Back</button></div></div>");
      } else if (level_index == 2) {
        html.add(
            "<div class='menu-container'><div class='info-box'><img src='res/HowToJump.png'></img><br><br><button class='button'>Start</button><br><br><button class='cancel-button'>Back</button></div></div>");
      } else if (level_index == 5) {
        html.add(
            "<div class='menu-container'><div class='info-box'><img src='res/HowToMask.png'></img><br><br><button class='button'>Start</button><br><br><button class='cancel-button'>Back</button></div></div>");
      } else if (level_index == 6) {
        html.add(
            "<div class='menu-container'><div class='info-box'><img src='res/HowToSyringe.png'></img><br><br><button class='button'>Start</button><br><br><button class='cancel-button'>Back</button></div></div>");
      }

      levels[level_index]['seen'] = 'false';
      model.storage['levels'] = jsonEncode(levels);
      document.getElementById('view-container')?.innerHtml = html.join();
      return false;
    } else {
      goTo('Start');
      return true;
    }
  }

  void update(var tick) {
    /*Damit Herr Kratzke ZOOOOMEN kann */
    model.height =
        (querySelector('#street-container')?.getBoundingClientRect()?.height ??
            0.0) as double;
    if (!model.getLevelEnd()) {
      var margin_bottom = model.height - model.doctor.width - 50;
      model.doctor.yPos = margin_bottom;
      /*Was er aber ja nicht wird*/
    }

    street.style?.backgroundPositionY = '${model.street.yPos.toInt()}px';

    doctor.style?.top = '${model.doctor.yPos.toInt()}px';
    doctor.style?.left = '${model.doctor.xPos.toInt()}px';
    for (var i = 0; i < model.actors.length; i++) {
      enemys[i].style?.top = '${model.actors[i].yPos.toInt()}px';
      enemys[i].style?.left = '${model.actors[i].xPos.toInt()}px';

      if (!model.actors[i].alive) {
        model.actors.remove(model.actors[i]);
        enemys[i].remove();
        enemys.remove(enemys[i]);
        i--;
      }
    }
    if (tick % 10 == 0) updateScore();
    updateItems(model.doctor.syringeScore, model.doctor.maskScore);
    if (model.doctor.deadlyvirusSafe || model.doctor.virusSafe) {
      if (model.doctor.deadlyvirusSafe) {
        usingSyringe();
      }
      if (model.doctor.virusSafe) {
        usingMask();
      }
    } else {
      notusingItem();
    }
  }
}
