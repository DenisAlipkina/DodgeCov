import 'dart:math';

import 'Actor.dart';
import 'Doctor.dart';

class Barricade extends Actor {
  // var count = 0;
  bool lastHit = false;
  Barricade(field, xPos, yPos, speed) : super(field, xPos, yPos, speed);

  @override
  void move() {
    if (!field.inPosition) yPos = yPos + speed;

    if (detectCollision(field.doctor)) {
      field.doctor.alive = false;
      field.collision_with(this);
    }

    if (field.height <= yPos) alive = false;
  }

  @override
  bool detectCollision(Doctor player) {
    /// xPos = oben links
    var barricadeTopLeft = Point(xPos, yPos);

    /// xPos + breite = oben rechts
    var barricadeTopRight = Point(xPos + width, yPos);

    /// xPos + height = unten links
    var barricadeBotLeft = Point(xPos, yPos + height);

    /// xPos + height + width = unten rechts
    var barricadeBotRight = Point(xPos + width, yPos + height);

    var vertical_left = detectCollision2(player, barricadeTopLeft,
        Point(barricadeBotLeft.x, barricadeBotLeft.y + 23));
    var vertical_right = detectCollision2(player, barricadeTopRight,
        Point(barricadeBotRight.x, barricadeBotRight.y + 23));
    var horizontal = detectCollision2(
        player,
        Point(barricadeBotLeft.x + 13, barricadeBotLeft.y),
        Point(barricadeBotRight.x - 13, barricadeBotRight.y));
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

  bool collisionWithPoint(var barricadeX, var barricadeY, Doctor player) {
    var player_center_xPos = player.xPos + player.width / 2;
    var player_center_yPos = player.yPos + player.width / 2;

    return (sqrt(pow(player_center_xPos - barricadeX, 2) +
            pow(player_center_yPos - barricadeY, 2)) <=
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
