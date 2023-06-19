import 'dart:math';

import 'Actor.dart';
import 'Doctor.dart';

class Drain extends Actor {
  Drain(field, xPos, yPos, speed) : super(field, xPos, yPos, speed);

  @override
  void move() {
    if (!field.inPosition) yPos = yPos + speed;

    if (detectCollision(field.doctor)) {
      field.doctor.alive = false;
      field.collision_with(this);
    }

    if (field.height + 200 <= yPos) alive = false;
  }

  @override
  bool detectCollision(Doctor player) {
    var player_center_xPos = player.xPos + player.width / 2;
    var player_center_yPos = player.yPos + player.width / 2;
    var virus_center_xPos = xPos + width / 2;
    var virus_center_yPos = yPos + width / 2;
    return (sqrt(pow(player_center_xPos - virus_center_xPos, 2) +
                pow(player_center_yPos - virus_center_yPos, 2)) <
            (width / 2 + (player.width / 2 - 25))) &&
        !player.jumping;
    /* -25 da der Doctor in den Drain reinlaufen soll. Nicht nur berühren */
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
  void jump() {}
}
