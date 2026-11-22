class ServicePrice {
  final int amountTnd;
  final String period;

  const ServicePrice(this.amountTnd, {this.period = 'month'});
}

// Placeholder prices: edit these.
class ServicePricing {
  static const rainForecast = ServicePrice(29);
  static const aiAssistant = ServicePrice(39);
  static const marketForecast = ServicePrice(49);
}