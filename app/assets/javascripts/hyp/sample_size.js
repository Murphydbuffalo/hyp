class SampleSize {
  listen() {
    this.fetchSampleSizeOn('.alpha select', 'change');
    this.fetchSampleSizeOn('.power select', 'change');
    this.fetchSampleSizeOn('.control input', 'keyup');
    this.fetchSampleSizeOn('.minimum_detectable_effect input', 'input');
  }

  fetchSampleSizeOn(selector, eventName) {
    document.querySelector(selector).addEventListener(eventName, () => { this.fetch() });
  }

  fetch() {
    if (this.allParametersPresent()) {
      $.get(
        '/hyp/sample_size',
        {
          alpha:                     this.alpha() / 100.0,
          power:                     this.power() / 100.0,
          control:                   this.control() / 100.0,
          minimum_detectable_effect: this.minimumDetectableEffect() / 100.0
        }, (data, _status, _xhr) => {
          this.updateSampleSize(data.result);
          this.updateTooltipDescription();
        }
      );
    }
  }

  updateSampleSize(sampleSize) {
    document.querySelector('.sample-size').textContent = sampleSize;
  }

  updateTooltipDescription() {
    let message;

    if (this.allParametersPresent()) {
      message = `This sample size guarantees you a ${this.power()}% chance of finding a significant result if it is present given an effect size of at least ${this.minimumDetectableEffect()}%, alpha of ${this.alpha()}%, and your baseline conversion rate of ${this.control()}%.`;
    } else {
      message = "Please fill out all fields to see your required sample size.";
    }

    document.querySelector('.sample-size-tooltip').setAttribute("title", message);
  }

  allParametersPresent() {
    return [
      this.alpha(),
      this.power(),
      this.control(),
      this.minimumDetectableEffect()
    ].every(parameter => { return parameter > 0 });
  }

  alpha() {
    return this.percentageValue('.alpha select');
  }

  power() {
    return this.percentageValue('.power select');
  }

  control() {
    return this.percentageValue('.control input');
  }

  minimumDetectableEffect() {
    return this.percentageValue('.minimum_detectable_effect input');
  }

  percentageValue(selector) {
    // Using `+` will truncate any trailing zeros
    return +(this.decimalValue(selector) * 100.0).toFixed(2);
  }

  decimalValue(selector) {
    return parseFloat(document.querySelector(selector).value);
  }
}
