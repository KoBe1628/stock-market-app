console.log("Navigation script loaded (W1)");

const MARKETSTACK_KEY = "6e3a56296011e1584ed80a8461f9ecf4";

async function detectLocationAndFetchStocks() {
  if ("geolocation" in navigator) {
    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const { latitude, longitude } = position.coords;

        const geoRes = await fetch(
          `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitude}`
        );
        const geoData = await geoRes.json();
        const countryCode = geoData.address?.country_code?.toUpperCase();

        if (!countryCode) {
          alert("Could not determine country from your location.");
          return;
        }

        console.log("Country Code:", countryCode);

        let stocks = [];
        let latestMap = {};
        let usingMock = false;

        try {
          const marketRes = await fetch(
            `http://api.marketstack.com/v1/tickers?access_key=${MARKETSTACK_KEY}&limit=10&country=${countryCode}`
          );
          const marketData = await marketRes.json();
          stocks = marketData.data || [];

          const symbols = stocks.map((s) => s.symbol).join(",");
          const latestRes = await fetch(
            `http://api.marketstack.com/v1/eod/latest?access_key=${MARKETSTACK_KEY}&symbols=${symbols}`
          );
          const latestData = await latestRes.json();

          latestData.data.forEach((item) => {
            latestMap[item.symbol] = item;
          });
        } catch (err) {
          console.warn("Falling back to mock stock data.");
          usingMock = true;

          stocks = [
            { name: "Microsoft Corporation", symbol: "MSFT" },
            { name: "Apple Inc", symbol: "AAPL" },
            { name: "Amazon.com Inc", symbol: "AMZN" },
            { name: "Alphabet Inc - Class C", symbol: "GOOG" },
            { name: "Alphabet Inc - Class A", symbol: "GOOGL" },
          ];

          latestMap = {
            MSFT: { change_percent: +2.35 },
            AAPL: { change_percent: -1.0 },
            AMZN: { change_percent: 0 },
            GOOG: { change_percent: +0.82 },
            GOOGL: { change_percent: -0.58 },
          };
        }

        const stockContainer = document.createElement("div");
        stockContainer.className = "stock-box";
        stockContainer.innerHTML = `<h3>Top Stocks in ${countryCode}</h3>`;

        if (stocks.length === 0) {
          stockContainer.innerHTML += `<p>No stock data found for your country.</p>`;
        } else {
          const visibleStocks = stocks.filter(
            (stock) => latestMap[stock.symbol]
          );

          stockContainer.innerHTML += `
          <ul>
            ${visibleStocks
              .map((stock) => {
                const item = latestMap[stock.symbol];
                const change = item?.change_percent;
                let className = "neutral";
                let display = "N/A";

                if (typeof change === "number") {
                  if (change > 0) {
                    className = "positive";
                    display = `+${change.toFixed(2)}%`;
                  } else if (change < 0) {
                    className = "negative";
                    display = `${change.toFixed(2)}%`;
                  } else {
                    display = "0.00%";
                  }
                }

                return `
                <li>
                  ${stock.name} (${stock.symbol})
                  <span class="${className}">${display}</span>
                </li>`;
              })
              .join("")}
          </ul>
        `;
        }

        document.body.appendChild(stockContainer);
      },
      (err) => {
        alert("Failed to get location: " + err.message);
      }
    );
  } else {
    alert("Geolocation is not supported.");
  }
}

window.addEventListener("load", detectLocationAndFetchStocks);
