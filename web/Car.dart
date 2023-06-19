import 'dart:math';

import 'Actor.dart';
import 'Doctor.dart';

class Car extends Actor {
  bool lastHit = false;
  Car(field, xPos, yPos, speed) : super(field, xPos, yPos, speed);

  @override
  void move() {
    if (!field.inPosition) {
      yPos = yPos + speed;
    } else {
      yPos = yPos + (speed - field.baseSpeed);
    }

    if (detectCollision(field.doctor)) {
      field.doctor.alive = false;
      field.collision_with(this);
    }

    if (field.height <= yPos) alive = false;
  }

  @override
  bool detectCollision(Doctor player) {
    /// xPos = oben links
    var carTopLeft = Point(xPos, yPos);

    /// xPos + breite = oben rechts
    var carTopRight = Point(xPos + width, yPos);

    /// xPos + height = unten links
    var carBotLeft = Point(xPos, yPos + height);

    /// xPos + height + width = unten rechts
    var carBotRight = Point(xPos + width, yPos + height);

    var vertical_left = detectCollision2(
        player, carTopLeft, Point(carBotLeft.x, carBotLeft.y + 23));
    var vertical_right = detectCollision2(
        player, carTopRight, Point(carBotRight.x, carBotRight.y + 23));
    var horizontal = detectCollision2(
        player,
        Point(carBotLeft.x + 13, carBotLeft.y),
        Point(carBotRight.x - 13, carBotRight.y));
    if (horizontal) {
      var playercenter = player.yPos + (player.width / 2) + (player.height / 2);
      if (playercenter - ((player.width / 2) - 20) - (yPos + height) >= 20) {
        return true;
      }
    }
    if (vertical_left) {
      player.moveable_right = false;
      player.moveable_left = true;
      lastHit = true;
    } else if (vertical_right) {
      player.moveable_left = false;
      player.moveable_right = true;
      lastHit = true;
    } else {
      if (lastHit) {
        player.moveable_right = true;
        player.moveable_left = true;
      } else {
        lastHit = false;
      }
    }
    return false;
  }

  bool detectCollision2(Doctor player, Point start, Point end) {
    if (start.x == end.x) {
      if (end.y <= start.y) return false;
      return collisionWithPoint(start.x, start.y, player) ||
          detectCollision2(player, Point(start.x, start.y + 5), end);
    } else {
      if (end.x <= start.x) return false;
      return collisionWithPoint(start.x, start.y, player) ||
          detectCollision2(player, Point(start.x + 5, start.y), end);
    }
  }

  bool collisionWithPoint(var carX, var carY, Doctor player) {
    var player_center_xPos = player.xPos + player.width / 2;
    var player_center_yPos = player.yPos + player.width / 2;

    return (sqrt(pow(player_center_xPos - carX, 2) +
            pow(player_center_yPos - carY, 2)) <=
        (player.width / 2));
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
