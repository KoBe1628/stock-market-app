const FINNHUB_API_KEY = "d1d6or1r01qic6lhho80d1d6or1r01qic6lhho8g";
const urlParams = new URLSearchParams(window.location.search);
const symbol = urlParams.get("symbol")?.toUpperCase() || "BTC";

const coinMeta = {
  BTC: { id: "bitcoin", name: "Bitcoin", image: "assets/icons/btc.png" },
  ETH: { id: "ethereum", name: "Ethereum", image: "assets/icons/eth.png" },
  DOGE: { id: "dogecoin", name: "Dogecoin", image: "assets/icons/doge.png" },
};

const isCrypto = !!coinMeta[symbol];
const type = isCrypto ? "crypto" : "stock";
console.log(`Selected symbol: ${symbol} | Type: ${type}`);

const STOCK_FALLBACKS = {
  AAPL: {
    fullName: "Apple",
    price: 213.55,
    change: 0.52,
    volume: 50000000,
    marketCap: 3000000000,
  },
  NFLX: {
    fullName: "Netflix",
    price: 1297.18,
    change: 0.96,
    volume: 12000000,
    marketCap: 200000000,
  },
  NKE: {
    fullName: "Nike",
    price: 102.55,
    change: 0.22,
    volume: 18000000,
    marketCap: 150000000,
  },
  AMZN: {
    fullName: "Amazon",
    price: 223.41,
    change: 1.56,
    volume: 18000000,
    marketCap: 200000000,
  },
};

function getFallbackData() {
  return {
    name: isCrypto ? "Unknown Coin" : `${symbol} Stock`,
    symbol: symbol,
    price: STOCK_FALLBACKS[symbol]?.price || 10000,
    change: STOCK_FALLBACKS[symbol]?.change || 0.0,
    volume: STOCK_FALLBACKS[symbol]?.volume || 0,
    marketCap: STOCK_FALLBACKS[symbol]?.marketCap || 0,
  };
}

function formatCurrency(value) {
  if (typeof value !== "number") return "$0.00";
  return (
    "$" +
    value.toLocaleString(undefined, {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    })
  );
}

function showFallbackBanner() {
  let existing = document.getElementById("fallback-banner");
  if (!existing) {
    const banner = document.createElement("div");
    banner.id = "fallback-banner";
    banner.textContent = "⚠️ Live data not available. Showing fallback values.";
    banner.style.backgroundColor = "#ffe6e6";
    banner.style.color = "#a94442";
    banner.style.padding = "8px";
    banner.style.margin = "10px 0";
    banner.style.border = "1px solid #f5c6cb";
    banner.style.borderRadius = "4px";
    banner.style.fontSize = "0.9rem";
    banner.style.textAlign = "center";
    document.querySelector("main")?.prepend(banner);
  }
}

function updateDetails(data, meta = {}, isFallback = false) {
  const fallback = getFallbackData();
  const name = !isFallback
    ? isCrypto
      ? data.name
      : `${symbol} Stock`
    : fallback.name;
  const sym = symbol;
  const price = !isFallback
    ? isCrypto
      ? data.market_data?.current_price?.usd
      : data.c
    : fallback.price;
  const change = !isFallback
    ? isCrypto
      ? data.market_data?.price_change_percentage_24h
      : data.dp
    : fallback.change;
  const volume = !isFallback
    ? isCrypto
      ? data.market_data?.total_volume?.usd
      : data.v
    : fallback.volume;
  const marketCap = !isFallback
    ? isCrypto
      ? data.market_data?.market_cap?.usd
      : data.mc || 0
    : fallback.marketCap;

  // Update name & price
  let displayName;
  if (isCrypto) {
    displayName = `${name}  ${symbol}`;
  } else {
    const fallback = STOCK_FALLBACKS[symbol];
    const fullName = fallback?.fullName || symbol;
    displayName = `${fullName}  ${symbol} Stock`;
  }
  document.getElementById("btc-name").textContent = displayName;

  document.getElementById("btc-price").textContent = formatCurrency(price);
  // const logoElem = document.getElementById("btc-logo");
  // logoElem.src = isCrypto ? meta.image : "assets/icons/default.png";
  // logoElem.alt = `${symbol} logo`;

  const changeElem = document.getElementById("btc-change");
  const formattedChange =
    change >= 0 ? `+${change.toFixed(2)}%` : `${change.toFixed(2)}%`;
  changeElem.textContent = formattedChange;
  changeElem.style.color = change > 0 ? "green" : change < 0 ? "red" : "gray";

  // Update volume and market cap
  document.getElementById("btc-volume").textContent = formatCurrency(volume);
  document.getElementById("btc-marketcap").textContent =
    formatCurrency(marketCap);

  // Dynamically update the icon if crypto
  const iconElem = document.getElementById("btc-logo");
  if (iconElem) {
    const localPath = `/assets/icons/${symbol.toLowerCase()}.png`;
    iconElem.src = localPath;
    iconElem.alt = isCrypto ? symbol : "Stock";
  }

  // Update back label and page title
  document.getElementById("page-title").textContent = name;

  // Show fallback banner if using mock data
  if (isFallback) {
    showFallbackBanner();
  }
}

async function loadData() {
  try {
    if (isCrypto) {
      const meta = coinMeta[symbol];
      const res = await fetch(
        `https://api.coingecko.com/api/v3/coins/${meta.id}`
      );
      if (!res.ok) throw new Error("Crypto API error");
      const data = await res.json();
      updateDetails(data, meta, false);
    } else {
      const res = await fetch(
        `https://finnhub.io/api/v1/quote?symbol=${symbol}&token=${FINNHUB_API_KEY}`
      );
      if (!res.ok) throw new Error("Stock API error");
      const data = await res.json();
      if (!data.c) throw new Error("Invalid stock data");
      updateDetails(data, {}, false);
    }
  } catch (err) {
    console.warn(
      "Symbol not supported or quote failed, using fallback.",
      err.message
    );
    updateDetails({}, {}, true);
  }
}

window.addEventListener("DOMContentLoaded", loadData);

// === Chart Rendering ===
let chartInstance = null;

async function renderChartWithFallback() {
  const ctx = document.getElementById("btcChart").getContext("2d");
  let labels = [
    "6d ago",
    "5d ago",
    "4d ago",
    "3d ago",
    "2d ago",
    "Yesterday",
    "Today",
  ];
  let prices = [];

  try {
    if (isCrypto) {
      const meta = coinMeta[symbol];
      const res = await fetch(
        `https://api.coingecko.com/api/v3/coins/${meta.id}/market_chart?vs_currency=usd&days=7`
      );
      const data = await res.json();
      prices = data.prices.map((p) => Math.round(p[1]));
      labels = data.prices.map((p) => {
        const date = new Date(p[0]);
        return date.toLocaleDateString("en-US", { weekday: "short" });
      });
    } else {
      throw new Error("Stock chart data disabled – using fallback");
    }
  } catch (err) {
    console.warn("⚠️ Chart API fallback:", err.message);
    prices = [10200, 10500, 10800, 10600, 10900, 11100, 11000];
  }

  if (chartInstance) chartInstance.destroy();

  chartInstance = new Chart(ctx, {
    type: "line",
    data: {
      labels,
      datasets: [
        {
          label: `${symbol} Price`,
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
        legend: { display: false },
      },
    },
  });
}

window.addEventListener("load", renderChartWithFallback);

// Add to Watchlist Button ---------------- //

function isInWatchlist(symbol) {
  const list = JSON.parse(localStorage.getItem("watchlist")) || [];
  return list.includes(symbol);
}

function addToWatchlist(symbol) {
  let list = JSON.parse(localStorage.getItem("watchlist")) || [];
  if (!list.includes(symbol)) {
    list.push(symbol);
    localStorage.setItem("watchlist", JSON.stringify(list));
  }
}

function setupWatchlistButton() {
  const btn = document.getElementById("watchlist-btn");
  if (!btn) return;

  if (isInWatchlist(symbol)) {
    btn.textContent = "In Watchlist";
    btn.disabled = true;
  }

  btn.addEventListener("click", () => {
    addToWatchlist(symbol);
    btn.textContent = "In Watchlist";
    btn.disabled = true;
  });
}

window.addEventListener("DOMContentLoaded", setupWatchlistButton);
