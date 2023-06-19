import 'dart:html';

import 'Controller.dart';
import 'Field.dart';
import 'View.dart';

void main() {
  var model = Field();
  var view = View(model);
  var controller = Controller(model, view);
  view.initialise();
  controller.keyMoved();
  controller.mouseEvent();
  window.requestAnimationFrame(controller.gameLoop);
}
