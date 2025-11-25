import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:vega_dashboard/screens/client_settings/screen_whatsapp.dart";

import "screen_settings.dart";

extension IntegrationsClientSettings on ClientSettingsScreenState {
  Widget buildIntegrationsSettingsMobileLayout() {
    return SingleChildScrollView(
        child: TextButton(onPressed: () => context.push(const WhatsappScreen()), child: const Text("Whatsapp")));
  }

  Widget buildIntegrationsSettingsDefaultLayout() {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(onPressed: () => context.push(const WhatsappScreen()), child: const Text("Whatsapp")),
        ],
      ),
    );
  }
}

// eof
