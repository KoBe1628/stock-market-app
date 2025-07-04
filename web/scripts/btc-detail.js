const COINGECKO_API = "https://api.coingecko.com/api/v3";
const FINNHUB_API = "https://finnhub.io/api/v1";
const FINNHUB_KEY = "d1cp2apr01qic6lf35s0d1cp2apr01qic6lf35sg";

// Get symbol and type from URL
const params = new URLSearchParams(window.location.search);
const symbol = (params.get("symbol") || "BTC").toUpperCase();
const type = (params.get("type") || "coin").toLowerCase();

// Chart setup
const chartCtx = document.getElementById("btcChart").getContext("2d");
let chartInstance = null;

function formatCurrency(value) {
  return "$" + Number(value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function updateUI({ name, price, change, volume, marketCap, image }) {
  document.querySelector("h2").textContent = name;
  document.getElementById("btc-name").textContent = `${symbol} ${name}`;
  document.getElementById("btc-price").textContent = formatCurrency(price);
  document.getElementById("btc-price-stats").textContent = formatCurrency(price);
  document.getElementById("btc-change").textContent = `${change >= 0 ? "+" : ""}${change.toFixed(2)}%`;
  document.getElementById("btc-change-stats").textContent = `${change >= 0 ? "+" : ""}${change.toFixed(2)}%`;
  document.getElementById("btc-volume").textContent = formatCurrency(volume);
  document.getElementById("btc-marketcap").textContent = marketCap ? formatCurrency(marketCap) : "—";
  document.querySelector(".coin-info img").src = image || "/assets/icons/bitcoin.svg";

  const changeEl = document.getElementById("btc-change");
  changeEl.classList.remove("positive", "negative", "neutral");
  changeEl.classList.add(change > 0 ? "positive" : change < 0 ? "negative" : "neutral");
}

async function loadCoinData() {
  const idMap = {
    BTC: "bitcoin",
    ETH: "ethereum",
    DOGE: "dogecoin",
    TR: "tether"
  };
  const coinId = idMap[symbol] || symbol.toLowerCase();

  const res = await fetch(`${COINGECKO_API}/coins/${coinId}`);
  const data = await res.json();

  const price = data.market_data.current_price.usd;
  const change = data.market_data.price_change_percentage_24h;
  const volume = data.market_data.total_volume.usd;
  const marketCap = data.market_data.market_cap.usd;
  const name = data.name;
  const image = data.image?.small;

  updateUI({ name, price, change, volume, marketCap, image });
}

async function loadStockData() {
  const [quoteRes, profileRes] = await Promise.all([
    fetch(`${FINNHUB_API}/quote?symbol=${symbol}&token=${FINNHUB_KEY}`),
    fetch(`${FINNHUB_API}/stock/profile2?symbol=${symbol}&token=${FINNHUB_KEY}`)
  ]);
  const quote = await quoteRes.json();
  const profile = await profileRes.json();

  updateUI({
    name: profile.name || symbol,
    price: quote.c,
    change: quote.dp,
    volume: quote.v || 0,
    marketCap: profile.marketCapitalization * 1e6 || null,
    image: profile.logo || "/assets/icons/stock.png"
  });
}

async function loadChart() {
  let labels = [], prices = [];

  if (type === "coin") {
    const idMap = {
      BTC: "bitcoin",
      ETH: "ethereum",
      DOGE: "dogecoin",
      TR: "tether"
    };
    const coinId = idMap[symbol] || symbol.toLowerCase();

    try {
      const res = await fetch(`${COINGECKO_API}/coins/${coinId}/market_chart?vs_currency=usd&days=7`);
      const data = await res.json();
      prices = data.prices.map(p => p[1]);
      labels = data.prices.map(p => new Date(p[0]).toLocaleDateString("en-US", { weekday: "short" }));
    } catch (err) {
      console.warn("Coin chart load failed:", err);
    }

  } else {
    try {
      const res = await fetch(`https://api.twelvedata.com/time_series?symbol=${symbol}&interval=1day&outputsize=7&apikey=406f8ddf843943edb6488bf770b85caf`);
      const data = await res.json();

      if (data && data.values) {
        const reversed = data.values.reverse(); // Ensure oldest-to-latest order
        prices = reversed.map(p => parseFloat(p.close));
        labels = reversed.map(p => new Date(p.datetime).toLocaleDateString("en-US", { weekday: "short" }));
      } else {
        console.warn("No stock chart data:", data);
      }
    } catch (err) {
      console.warn("Stock chart load failed:", err);
    }
  }

  if (!prices.length || !labels.length) {
    labels = ["No Data"];
    prices = [0];
  }

  if (chartInstance) chartInstance.destroy();

  chartInstance = new Chart(chartCtx, {
    type: "line",
    data: {
      labels,
      datasets: [{
        label: `${symbol} Price`,
        data: prices,
        borderColor: "#14b866",
        borderWidth: 2,
        fill: false,
        tension: 0.3,
        pointRadius: 3,
        pointBackgroundColor: "#14b866"
      }]
    },
    options: {
      responsive: true,
      plugins: { legend: { display: false } },
      scales: {
        y: {
          ticks: {
            callback: (val) => `$${val.toLocaleString()}`
          }
        }
      }
    }
  });
}



// Load everything
window.addEventListener("DOMContentLoaded", async () => {
  try {
    if (type === "coin") {
      await loadCoinData();
    } else {
      await loadStockData();
    }
    await loadChart();
  } catch (err) {
    console.error("Detail page load error:", err);
  }
});



document.addEventListener("DOMContentLoaded", async () => {
  const locationEl = document.getElementById("location-display");

  try {
    const res = await fetch("https://api.country.is/");
    const data = await res.json();

    const countryCode = data.country; // 2-letter code
    const flagUrl = `https://flagsapi.com/${countryCode}/flat/24.png`;

    locationEl.innerHTML = `
      <img src="${flagUrl}" alt="${countryCode} flag" />
      ${countryCode}
    `;
  } catch (err) {
    locationEl.textContent = "Location unavailable";
    console.error("Location detection error:", err);
  }
});

