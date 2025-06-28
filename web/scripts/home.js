console.log("Home JS is loaded"); // Confirm it's running

// === API KEYS ===
const NEWS_API_KEY = "bb407e0ae5664bcc1b8edf572ce91b10";
const FINNHUB_API_KEY = "d1d6or1r01qic6lhho80d1d6or1r01qic6lhho8g";

// === ENDPOINTS ===
const NEWS_ENDPOINT = `https://gnews.io/api/v4/search?q=stocks&lang=en&token=${NEWS_API_KEY}`;
const STOCK_SYMBOLS = ["AAPL", "NFLX", "AMZN", "NKE"];
const CRYPTO_SYMBOLS = ["BTCUSDT", "ETHUSDT", "DOGEUSDT"];
const CRYPTO_NAME_MAP = {
  BTCUSDT: "BTC",
  ETHUSDT: "ETH",
  DOGEUSDT: "DOGE",
};

// === ICON MAPPINGS ===
const stockLogoMap = {
  AAPL: "../assets/icons/apple.png",
  NFLX: "../assets/icons/netflix.png",
  AMZN: "../assets/icons/amazon.png",
  NKE: "../assets/icons/nike.png",
};

const cryptoLogoMap = {
  BTC: "../assets/icons/btc.png",
  ETH: "../assets/icons/eth.png",
  DOGE: "../assets/icons/doge.png",
};

// === ON LOAD ===
document.addEventListener("DOMContentLoaded", () => {
  fetchNews();
  fetchStocks();
  fetchCrypto();
  loadMarketSnapshot();
});

// === NEWS ===
async function fetchNews() {
  try {
    const response = await fetch(NEWS_ENDPOINT);
    const data = await response.json();
    loadNewsFeed(data);
  } catch (error) {
    console.error("Error fetching news:", error);
    loadNewsFeed({ articles: [] });
  }
}

function loadNewsFeed(data) {
  const container = document.querySelector(".news-feed");
  const articles = data.articles || [];
  const seenTitles = new Set();
  const uniqueArticles = [];

  for (const article of articles) {
    if (!seenTitles.has(article.title)) {
      seenTitles.add(article.title);
      uniqueArticles.push(article);
    }
    if (uniqueArticles.length === 3) break;
  }

  container.innerHTML = `<h2>Today's News</h2>`;

  uniqueArticles.forEach((article) => {
    const card = document.createElement("div");
    card.className = "news-card";
    card.innerHTML = `
      <a href="${
        article.url
      }" target="_blank" rel="noopener noreferrer" class="news-card-link">
        <img src="${article.image}" alt="news" class="news-image" />
        <div class="news-content">
          <p class="news-title">${article.title}</p>
          <p class="news-source">${
            article.source.name
          } · ${article.publishedAt.slice(11, 16)}</p>
        </div>
      </a>
    `;
    container.appendChild(card);
  });

  const btn = document.createElement("button");
  btn.className = "view-all-news";
  btn.textContent = "View All News";
  btn.onclick = () => window.open("https://gnews.io/", "_blank");
  container.appendChild(btn);
}

// === STOCKS (via Finnhub) ===
async function fetchStocks() {
  const results = [];
  for (const symbol of STOCK_SYMBOLS) {
    try {
      const url = `https://finnhub.io/api/v1/quote?symbol=${symbol}&token=${FINNHUB_API_KEY}`;
      const res = await fetch(url);
      const data = await res.json();
      results.push({ symbol, ...data });
    } catch (err) {
      console.warn("Fallback stock:", symbol, err);
      results.push({ symbol, c: 100, pc: 95 });
    }
  }
  loadStockCards(results);
}

function loadStockCards(stocks) {
  const container = document.querySelector(".movers-grid");
  container.innerHTML = "";

  stocks.forEach((stock) => {
    const change = ((stock.c - stock.pc) / stock.pc) * 100;
    const symbol = stock.symbol;
    const logoUrl = stockLogoMap[symbol] || "assets/icons/default.png";

    const card = document.createElement("div");
    card.className = "mover";
    card.innerHTML = `
      <img src="${logoUrl}" alt="${symbol}" class="coin-logo" />
      ${symbol} <span class="${change >= 0 ? "green" : "red"}">${change.toFixed(
      3
    )}%</span>
    `;
    container.appendChild(card);
  });
}

// === CRYPTO (via Finnhub using Binance symbols) ===
async function fetchCrypto() {
  const results = [];
  for (const symbol of CRYPTO_SYMBOLS) {
    try {
      const url = `https://finnhub.io/api/v1/quote?symbol=BINANCE:${symbol}&token=${FINNHUB_API_KEY}`;
      const res = await fetch(url);
      const data = await res.json();
      results.push({ symbol, ...data });
    } catch (err) {
      console.warn("Fallback crypto:", symbol, err);
      results.push({ symbol, c: 100, pc: 92 });
    }
  }
  loadCryptoCards(results);
}

function loadCryptoCards(data) {
  const container = document.querySelector(".crypto-grid");
  container.innerHTML = "";

  data.forEach((coin) => {
    const symbol = CRYPTO_NAME_MAP[coin.symbol] || coin.symbol;
    const change = ((coin.c - coin.pc) / coin.pc) * 100;
    const logoUrl = cryptoLogoMap[symbol] || "assets/icons/default.png";

    const card = document.createElement("div");
    card.className = "crypto";
    card.innerHTML = `
      <img src="${logoUrl}" alt="${symbol}" class="coin-logo" />
      ${symbol} <span class="${change >= 0 ? "green" : "red"}">${change.toFixed(
      3
    )}%</span>
    `;
    container.appendChild(card);
  });
}

// === SNAPSHOT MOCK ===
function loadMarketSnapshot() {
  const snapshot = document.querySelector(".snapshot-box h3");
  if (snapshot) {
    const mockValue = "$3 231 772 409 115,81";
    snapshot.textContent = mockValue;
  }
}
