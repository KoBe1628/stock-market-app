// === BASE SCRIPT ===
// Will handle things like search interactions or future navigation logic

console.log("Navigation script loaded (W1)");

// === Location Detection Logic (W3-1) ===

function detectLocation() {
  if ("geolocation" in navigator) {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        console.log(`User location detected: ${latitude}, ${longitude}`);

        // You can later use these coordinates to fetch location-based stock data
        // For now, we'll just show it on the page as proof
        const output = document.createElement("div");
        output.className = "location-box";
        output.innerHTML = `
            <h3>Your Location</h3>
            <p>${latitude.toFixed(4)}, ${longitude.toFixed(4)}</p>
        `;
        document.body.appendChild(output);
      },
      (error) => {
        console.error("Geolocation error:", error.message);
        alert("Unable to retrieve your location.");
      }
    );
  } else {
    alert("Geolocation is not supported by your browser.");
  }
}

// Run it when page loads
window.addEventListener("load", detectLocation);
