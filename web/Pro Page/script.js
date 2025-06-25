document.addEventListener("DOMContentLoaded", function () {
  const pricingButtons = document.querySelectorAll(".pricing-button");

  pricingButtons.forEach((btn) => {
    btn.addEventListener("click", () => {
      pricingButtons.forEach((b) => b.classList.remove("selected"));
      btn.classList.add("selected");
    });
  });
});
