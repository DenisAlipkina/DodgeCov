import 'Actor.dart';
import 'Doctor.dart';
import 'Field.dart';
import 'dart:math';

class Hospital extends Actor {
  Hospital(Field f, double x, double y, double s) : super(f, x, y, s);

  @override
  bool detectCollision(Doctor player) {
    /// xPos + height = unten links
    var hospitalBotLeft = Point(xPos, yPos + height);

    /// xPos + height + width = unten rechts
    var hospitalBotRight = Point(xPos + width, yPos + height);

    var horizontal = detectCollision2(
        player,
        Point(hospitalBotLeft.x, hospitalBotLeft.y),
        Point(hospitalBotRight.x, hospitalBotRight.y));

    return horizontal;
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

  bool collisionWithPoint(var hospitalX, var hospitalY, Doctor player) {
    var player_center_xPos = player.xPos + player.width / 2;
    var player_center_yPos = player.yPos + player.width / 2;

    return (sqrt(pow(player_center_xPos - hospitalX, 2) +
            pow(player_center_yPos - hospitalY, 2)) <=
        (player.width / 2));
  }

  @override
  void item_break() {}
  @override
  void jump() {}
  @override
  void move() {
    if ((yPos + speed) <= 0) {
      yPos = yPos + speed;
    } else {
      field.setinPosition();
    }
    if (detectCollision(field.doctor)) {
      field.collision_with(this);
      field.setFinished();
    }
  }

  @override
  void pace() {}
  @override
  void trackPlayer(Doctor player) {}
  @override
  void updateSize() {}
}
