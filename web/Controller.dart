import 'dart:html';
import 'Doctor.dart';
import 'Field.dart';
import 'Mask.dart';
import 'Syringe.dart';
import 'View.dart';

class Controller {
  Field model;
  View view;
  var timeCollectedSyringe = 0, timeCollectedMask = 0, spawn = 1;

  Controller(this.model, this.view);

  void gameLoop(num delta) {
    if (model.started) {
      spawn += 1;
      if (spawn % 10 == 0) model.updateScore(1);
      if (!model.doctor.jumping) view.playerRun();
      if (!model.nearlyFinished) {
        model.toGenerate(spawn).forEach((elem) {
          view.generateEnemy(elem[0], elem[1], elem[2]);
        });
      }
      model.moveStreet();
      model.moveDoctor();
      model.moveEnemy();
      model.updateDistance(1);
      if (model.killer != null) {
        if (model.killer is Syringe) {
          view.collectedSyringe = true;
          model.updateScore(20);
          model.killer = null;
        }
        if (model.killer is Mask) {
          view.collectedMask = true;
          model.updateScore(10);
          model.killer = null;
        }
      }
      if (view.collectedSyringe) {
        if (timeCollectedSyringe == 0) {
          view.showPlusPoints('syringe');
          timeCollectedSyringe = spawn;
        } else if (timeCollectedSyringe <= spawn - 100) {
          view.hidePlusPoints('syringe');
          timeCollectedSyringe = 0;
          view.collectedSyringe = false;
        }
      }
      if (view.collectedMask) {
        if (timeCollectedMask == 0) {
          view.showPlusPoints('mask');
          timeCollectedMask = spawn;
        } else if (timeCollectedMask <= spawn - 100) {
          view.hidePlusPoints('mask');
          timeCollectedMask = 0;
          view.collectedMask = false;
        }
      }
      if (model.detectLevelEnd() && !model.getLevelEnd()) {
        view.generateEnemy('hospital', model.baseSpeed, 0);
        model.setLevelEnd();
      }
      if (model.finished) {
        model.reCalculatePoints();
        view.updateScore();
        view.gameEnd();
        model.levelFinished();
        model.started = false;
      }
      if (!model.doctor.alive) {
        model.started = false;
        view.updateScore();
        view.gameEnd();
      }
      view.update(spawn);
    }
    Future.delayed(Duration(milliseconds: (1000 / 100) as int),
        () => window.requestAnimationFrame(gameLoop));
  }

  Future<void> mouseEvent() async {
    window.onClick.listen((MouseEvent e) {
      var text = '';
      if ((e.target is ButtonElement)) text = (e.target as ButtonElement).text!;

      if (text == 'Start' || text == 'Restart') {
        model.setDoctor(Doctor(model, 300, 0, model.playerSpeed));
        model.resetLevel();
        spawn = 0;
        model.started = true;
        view.goTo(text);
      } else if (!text.contains('Selection') && text.contains('Level ')) {
        model.loadLevel(model.config[int.parse(text.substring(5)) - 1]);
        if (view.handleTutorials(int.parse(text.substring(5)) - 1)) {
          model.started = true;
        }
      } else if (text == 'Next Level') {
        model.loadLevel(model.config[model.level]);
        view.reset();
        if (view.handleTutorials(model.level - 1)) {
          model.started = true;
        }
        view.goTo('Restart');
      } else if (text == 'Continue') {
        model.started = true;
        view.goTo('Continue');
      } else {
        view.goTo(text);
      }
    });
  }

  /* Hier wird geprüft ob der Player aktiv nach rechts bzw. nach links läuft */
  void keyMoved() {
    window.onKeyDown.listen((event) {
      switch (event.keyCode) {
        case KeyCode.LEFT:
          model.docSetLeft(true);
          break;
        case KeyCode.RIGHT:
          model.docSetRight(true);
          break;
        case KeyCode.SPACE:
          if (!model.doctor.jumping && model.doctor.alive) {
            model.doctor.jump();
            view.playerJump();
          }
          break;
        case KeyCode.Q:
          model.doctor.use_item('syringe');
          break;
        case KeyCode.E:
          model.doctor.use_item('mask');
          break;
        case KeyCode.ESC:
          if (!model.finished && model.started) {
            view.pause();
            model.started = false;
          }
      }
    });
    window.onKeyUp.listen((event) {
      switch (event.keyCode) {
        case KeyCode.LEFT:
          model.docSetLeft(false);
          break;
        case KeyCode.RIGHT:
          model.docSetRight(false);
          break;
      }
    });
  }
}
