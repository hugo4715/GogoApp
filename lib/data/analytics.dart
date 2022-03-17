import 'package:gogo_app/settings.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

late Mixpanel mixpanel;

Future<void> initMixpanel() async {
  mixpanel = await Mixpanel.init(mixpanelToken);
  mixpanel.setLoggingEnabled(true);
}