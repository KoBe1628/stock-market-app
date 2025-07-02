// === BTC Detail Page Script ===

const BTC_API_URL = "https://api.coingecko.com/api/v3/coins/bitcoin";

const mockBTCData = {
  name: "Bitcoin",
  symbol: "BTC",
  price: 84146.7,
  change: +0.29,
  volume: 25800000000,
  marketCap: 1188367000,
};

function formatCurrency(value) {
  return (
    "$" +
    value.toLocaleString(undefined, {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    })
  );
}

function updateBTCDetails(data) {
  const name = data.name || mockBTCData.name;
  const symbol = data.symbol?.toUpperCase() || mockBTCData.symbol;
  const price = data.market_data?.current_price?.usd || mockBTCData.price;
  const change =
    data.market_data?.price_change_percentage_24h || mockBTCData.change;
  const volume = data.market_data?.total_volume?.usd || mockBTCData.volume;
  const marketCap = data.market_data?.market_cap?.usd || mockBTCData.marketCap;

  document.getElementById("btc-name").textContent = `${symbol} ${name}`;
  document.getElementById("btc-price").textContent = formatCurrency(price);

  const changeElem = document.getElementById("btc-change");
  const formattedChange =
    change >= 0 ? `+${change.toFixed(2)}%` : `${change.toFixed(2)}%`;
  changeElem.textContent = formattedChange;
  changeElem.style.color = change > 0 ? "green" : change < 0 ? "red" : "gray";

  document.getElementById("btc-volume").textContent = formatCurrency(volume);
  document.getElementById("btc-marketcap").textContent =
    formatCurrency(marketCap);
}

async function loadBTCData() {
  try {
    const response = await fetch(BTC_API_URL);
    if (!response.ok) throw new Error("API Error");
    const data = await response.json();
    updateBTCDetails(data);
  } catch (err) {
    console.warn("Falling back to mock data:", err.message);
    updateBTCDetails({});
  }
}

window.addEventListener("DOMContentLoaded", loadBTCData);

let btcChartInstance = null; // global reference to chart

async function renderBTCChartWithFallback() {
  const ctx = document.getElementById("btcChart").getContext("2d");

  let labels = [];
  let prices = [];

  try {
    const response = await fetch(
      "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=7"
    );
    const data = await response.json();

    prices = data.prices.map((p) => Math.round(p[1]));
    labels = data.prices.map((p) => {
      const date = new Date(p[0]);
      return date.toLocaleDateString("en-US", { weekday: "short" });
    });
  } catch (err) {
    console.warn("⚠️ Falling back to mock BTC chart data.", err);

    labels = [
      "6d ago",
      "5d ago",
      "4d ago",
      "3d ago",
      "2d ago",
      "Yesterday",
      "Today",
    ];
    prices = [79100, 80250, 80800, 82000, 84300, 86000, 84146];
  }

  if (btcChartInstance) {
    btcChartInstance.destroy();
  }

  btcChartInstance = new Chart(ctx, {
    type: "line",
    data: {
      labels: labels,
      datasets: [
        {
          label: "BTC Price",
          data: prices,
          borderColor: "#14b866",
          borderWidth: 2,
          fill: false,
          tension: 0.3,
          pointRadius: 4,
          pointBackgroundColor: "#14b866",
        },
      ],
    },
    options: {
      responsive: true,
      scales: {
        y: {
          beginAtZero: false,
          ticks: {
            callback: (value) => `$${value.toLocaleString()}`,
          },
        },
      },
      plugins: {
        legend: {
          display: false,
        },
      },
    },
  });
}

window.addEventListener("load", renderBTCChartWithFallback);


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

