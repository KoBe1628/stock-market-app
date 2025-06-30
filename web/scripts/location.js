console.log("Location script loaded");

const OPEN_CAGE_API_KEY = "a69998c78f374bc3ba1ef54a27afeeea";

function updateLocationText(country, flagEmoji) {
  const locationElement = document.getElementById("user-location");
  if (locationElement) {
    locationElement.innerHTML = `${country} ${flagEmoji}`;
  }
}

function getFlagEmoji(countryCode) {
  // Turn country code into emoji: e.g., "DE" → 🇩🇪
  return countryCode
    .toUpperCase()
    .replace(/./g, (char) => String.fromCodePoint(127397 + char.charCodeAt()));
}

function detectUserLocation() {
  if (!navigator.geolocation) {
    console.warn("Geolocation is not supported by this browser.");
    return;
  }

  navigator.geolocation.getCurrentPosition(
    async (position) => {
      const { latitude, longitude } = position.coords;

      try {
        const response = await fetch(
          `https://api.opencagedata.com/geocode/v1/json?q=${latitude}+${longitude}&key=${OPEN_CAGE_API_KEY}`
        );

        const data = await response.json();
        const country = data.results[0].components.country;
        const countryCode = data.results[0].components["ISO_3166-1_alpha-2"];
        updateLocationText(country, getFlagEmoji(countryCode));
      } catch (error) {
        console.error("Error with OpenCage reverse geocoding:", error);
      }
    },
    (error) => {
      console.warn("Geolocation error:", error.message);
    }
  );
}

detectUserLocation();
