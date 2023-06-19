import 'dart:math';
import 'Actor.dart';
import 'Doctor.dart';

class Syringe extends Actor {
  Syringe(field, xPos, yPos, speed) : super(field, xPos, yPos, speed);

  @override
  void move() {
    if (!field.inPosition) {
      yPos = yPos + speed;
    } else {
      yPos = yPos + (speed - field.baseSpeed);
    }
    if (detectCollision(field.doctor)) {
      field.collision_with(this);
      field.doctor.syringeScore += 1;
      item_break();
    }
    if (field.height <= yPos) alive = false;
  }

  @override
  bool detectCollision(Doctor player) {
    var player_center_xPos = player.xPos + player.width / 2;
    var player_center_yPos = player.yPos + player.width / 2;
    var syringe_center_xPos = xPos + width / 2;
    var syringe_center_yPos = yPos + width / 2;
    return sqrt(pow(player_center_xPos - syringe_center_xPos, 2) +
            pow(player_center_yPos - syringe_center_yPos, 2)) <
        (width / 2 + player.width / 2);
  }

  @override
  void item_break() {
    alive = false;
  }

  @override
  void updateSize() {}
  @override
  void pace() {}
  @override
  void trackPlayer(Doctor player) {}
  @override
  void jump() {}
}
