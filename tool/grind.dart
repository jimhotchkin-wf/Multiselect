import 'dart:io';
import 'package:grinder/grinder.dart';

void main(List<String> args) {
  coverage();
}

@Task('Gather and send coverage data')
void coverage() {
  // coveralls doesn't seem to work for html tests
  if (Platform.environment['COVERALLS_TOKEN'] != null) {
    // report to coveralls
    Pub.global.activate('dart_coveralls');
    run('dart_coveralls', arguments: ['report', 'test/all.dart']);
  } else {
    // run coverage locally
    Pub.global.run('dart_dev', arguments: ['coverage']);
  }
}
