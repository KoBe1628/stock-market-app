document.addEventListener("DOMContentLoaded", () => {
  const pricingButtons = document.querySelectorAll(".pricing-button");

  pricingButtons.forEach((btn) => {
    btn.addEventListener("click", () => {
      pricingButtons.forEach((b) => b.classList.remove("selected"));
      btn.classList.add("selected");
    });
  });

  const locationEl = document.getElementById("location-display");

  fetch("https://api.country.is/")
    .then(res => res.json())
    .then(data => {
      const flagUrl = `https://flagsapi.com/${data.country}/flat/24.png`;
      locationEl.innerHTML = `<img src="${flagUrl}" alt="${data.country} flag" /> ${data.country}`;
    })
    .catch(() => {
      locationEl.textContent = "Location unavailable";
    });
});
