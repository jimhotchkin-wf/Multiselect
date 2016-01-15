library tool.dev;

import 'package:dart_dev/dart_dev.dart' show dev, config;

main(List<String> args) async {
  // https://github.com/Workiva/dart_dev

  // Perform task configuration here as necessary.

  // Available task configurations:
  config.analyze.entryPoints = ['src/multiselect.dart'];
  // config.copyLicense
  // config.coverage
  // config.docs
  // config.examples
  config.format
    ..directories = ['lib/', 'test/', 'tool/']
    ..lineLength = 120;
  // config.test

  await dev(args);
}
