import 'Field.dart';

class Street {
  double yPos;
  Field field;
  Street(this.field, this.yPos);

  void move(var speed) {
    if (!field.inPosition) yPos += speed;
  }
}
