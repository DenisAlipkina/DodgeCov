import 'dart:async';
import 'Actor.dart';

class Doctor extends Actor {
  @override
  late double dx;
  late bool left = false,
      right = false,
      moveable_left = true,
      moveable_right = true,
      deadlyvirusSafe = false,
      virusSafe = false;
  late int syringeScore = 0, maskScore = 0;

  Doctor(field, xPos, yPos, speed) : super(field, xPos, yPos, speed);

  @override
  void move() {
    if (field.inPosition) {
      yPos = yPos - field.baseSpeed;
    }
    if (!jumping) {
      if (moveable_left) {
        if (left && !right) {
          if (xPos > 0) {
            xPos = xPos - speed;
          }
        }
      }
      if (moveable_right) {
        if (right && !left) {
          if (xPos < (field.width - width)) {
            xPos = xPos + speed;
          }
        }
      }
    }
  }

  /* Setzt ob der Doctor nach Rechts oder nach Links läuft */
  void setLeft(bool left) => this.left = left;
  void setRight(bool right) => this.right = right;
  @override
  void jump() {
    jumping = true;
    Future.delayed(Duration(milliseconds: 750), () => jumping = false);
  }

  void use_item(var item) {
    if ('syringe' == item && syringeScore > 0) {
      syringeScore--;
      deadlyvirusSafe = true;
      virusSafe = false;
      Future.delayed(
          Duration(milliseconds: 1000), () => deadlyvirusSafe = false);
    }
    if ('mask' == item && maskScore > 0) {
      maskScore--;
      virusSafe = true;
      deadlyvirusSafe = false;
      Future.delayed(Duration(milliseconds: 1000), () => virusSafe = false);
    }
  }

  @override
  void item_break() {}
  @override
  void updateSize() {}
  @override
  void pace() {}
  @override
  void trackPlayer(Doctor player) {}
  @override
  bool detectCollision(Actor player) => false;
}
