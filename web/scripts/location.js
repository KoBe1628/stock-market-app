console.log("Location script loaded");

const locationContainer = document.getElementById("location-placeholder");

async function fetchUserLocation() {
  if (!locationContainer) {
    console.warn("Location placeholder element not found.");
    return;
  }

  try {
    if (!navigator.geolocation) {
      throw new Error("Geolocation not supported by your browser.");
    }

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const { latitude, longitude } = position.coords;

        try {
          const apiKey = "a69998c78f374bc3ba1ef54a27afeeea";
          const url = `https://api.opencagedata.com/geocode/v1/json?q=${latitude}+${longitude}&key=${apiKey}`;

          const response = await fetch(url);
          if (!response.ok)
            throw new Error(`OpenCage API error: ${response.status}`);

          const data = await response.json();
          const country = data.results?.[0]?.components?.country || "Unknown";
          const countryCode =
            data.results?.[0]?.components?.country_code?.toUpperCase() || "";

          locationContainer.innerHTML = `<strong>${country}</strong> <span style="font-size: 0.75rem;">${countryCode}</span>`;
        } catch (apiError) {
          console.error("API error:", apiError.message);
          locationContainer.innerHTML = `<span style="color: #999;">Could not fetch country info</span>`;
        }
      },
      (geoError) => {
        console.error("Geolocation error:", geoError.message);
        locationContainer.innerHTML = `<span style="color: #999;">Location access denied</span>`;
      }
    );
  } catch (err) {
    console.error("General error:", err.message);
    locationContainer.innerHTML = `<span style="color: #999;">Location unavailable</span>`;
  }
}

fetchUserLocation();
