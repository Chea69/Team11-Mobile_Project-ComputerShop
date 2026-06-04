import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NexusScrollBehavior extends MaterialScrollBehavior {
  const NexusScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  /// Emulators often deliver drags as mouse/trackpad; include all common kinds
  /// so nested lists and the home feed still scroll reliably.
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.mouse,
  };
}
