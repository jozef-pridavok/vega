import "package:core_dart/core_api_server2.dart";

import "../api_v1/client_payments.dart";
import "../api_v1/cron_handler.dart";
import "../api_v1/delivery_messages.dart";
import "../api_v1/notify_reservations.dart";
import "../api_v1/update_currency_rates.dart";
import "api_shelf.dart";
import "cron/cron.dart";
import "cron/human/human.dart";

extension CronApiHttpServer on CronApi {
  void cron() {
    final cron = Cron();

    _deliveryMessages(cron);
    _clientPayments(cron);
    _updateCurrencyRates(cron);
    //_notifyReservations(cron);
  }

  void _job(Cron cron, String config, CronHandler job) {
    if (config.isEmpty) {
      log.debug("${job.cronName}: not scheduled");
      return;
    }
    final schedule = Schedule.parse(config);
    log.debug("${job.cronName}: scheduled $config (${HumanCron.parse(config).toHuman()})");
    cron.schedule(schedule, () async {
      log.debug("${job.cronName}: ${DateTime.now()}");
      final context = ApiServerContext(this);
      final res = await job.execute(context, 100);
      log.debug("${job.cronName}: $res");
    });
  }

  void _deliveryMessages(Cron cron) => _job(cron, config.deliveryMessagesCron, DeliveryMessageHandler(this));

  void _clientPayments(Cron cron) => _job(cron, config.clientPaymentsCron, ClientPaymentHandler(this));

  void _updateCurrencyRates(Cron cron) => _job(cron, config.updateCurrencyRatesCron, UpdateCurrencyRatesHandler(this));

  void _notifyReservations(Cron cron) => _job(cron, config.notifyReservationsCron, NotifyReservationsHandler(this));
}

// eof

