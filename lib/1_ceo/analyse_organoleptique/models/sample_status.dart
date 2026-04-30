import 'package:flutter/material.dart';
import 'package:project3/core/theme/app_colors.dart';

const Color sampleStatusTintGreen = Color.fromARGB(255, 212, 225, 217);
const Color sampleStatusTintBlue = Color(0xFFEAF0F8);
const Color sampleStatusTintOrange = Color(0xFFFAF0E6);

enum SampleStatus { complete, partial, none }

extension SampleStatusStyle on SampleStatus {
  Color get color {
    switch (this) {
      case SampleStatus.complete:
        return kStatusGreen;
      case SampleStatus.partial:
        return kStatusBlue;
      case SampleStatus.none:
        return kStatusOrange;
    }
  }

  Color get tint {
    switch (this) {
      case SampleStatus.complete:
        return sampleStatusTintGreen;
      case SampleStatus.partial:
        return sampleStatusTintBlue;
      case SampleStatus.none:
        return sampleStatusTintOrange;
    }
  }
}
