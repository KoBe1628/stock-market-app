// === BASE SCRIPT ===
// Will handle things like search interactions or future navigation logic
console.log("Navigation script loaded (W1)");

// === W3-2: Geolocation + Marketstack API ===

const MARKETSTACK_KEY = '6e3a56296011e1584ed80a8461f9ecf4';

async function detectLocationAndFetchStocks() {
  if ('geolocation' in navigator) {
    navigator.geolocation.getCurrentPosition(async (position) => {
      const { latitude, longitude } = position.coords;

      const geoRes = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitude}`);
      const geoData = await geoRes.json();
      const countryCode = geoData.address?.country_code?.toUpperCase();

      if (!countryCode) {
        alert("Could not determine country from your location.");
        return;
      }

      console.log(`Detected country: ${countryCode}`);

      const marketRes = await fetch(`http://api.marketstack.com/v1/tickers?access_key=${MARKETSTACK_KEY}&limit=10&country=${countryCode}`);
      const marketData = await marketRes.json();

      const stocks = marketData.data || [];

      const stockContainer = document.createElement('div');
      stockContainer.className = 'stock-box';
      stockContainer.innerHTML = `<h3>Top Stocks in ${countryCode}</h3>`;

      if (stocks.length === 0) {
        stockContainer.innerHTML += `<p>No stock data found for your country.</p>`;
      } else {
        stockContainer.innerHTML += `
          <ul>
            ${stocks.map(stock => `<li>${stock.name} (${stock.symbol})</li>`).join('')}
          </ul>
        `;
      }

      document.body.appendChild(stockContainer);
    }, (err) => {
      alert("Failed to get location: " + err.message);
    });
  } else {
    alert("Geolocation is not supported.");
  }
}

window.addEventListener("load", detectLocationAndFetchStocks);

