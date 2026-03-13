import "package:logger/logger.dart";

final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 6,
    lineLength: 100,
    colors: true,
    printEmojis: false,
  ),
);
