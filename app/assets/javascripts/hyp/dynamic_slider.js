class DynamicSlider {
  constructor(inputSelector, displaySelector) {
    this.input   = document.querySelector(inputSelector);
    this.display = document.querySelector(displaySelector);
  }

  start() {
    this.input.addEventListener('input', (_event) => {
      this.display.textContent = this.input.value;
    });
  }
}
