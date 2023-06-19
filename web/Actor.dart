import 'Field.dart';
import 'Doctor.dart';

abstract class Actor {
  late double xPos, yPos, speed, height, width, dx, dy;
  late bool alive = true, jumping = false;
  late int points;
  late Field field;

  Actor(Field f, double x, double y, double s) {
    field = f;
    xPos = x;
    yPos = y;
    speed = s;
  }

  void setWidth(double w) {
    width = w;
  }

  void setHeigth(double h) {
    height = h;
  }

  void move();
  void jump();
  void item_break();
  void updateSize();
  void pace();
  void trackPlayer(Doctor player);
  bool detectCollision(Doctor player);
}
