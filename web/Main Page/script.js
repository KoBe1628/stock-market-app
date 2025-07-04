const apiKey = "d1cp2apr01qic6lf35s0d1cp2apr01qic6lf35sg";
const newsCarousel = document.getElementById("news-carousel");

async function fetchNews() {
  try {
    const response = await fetch(`https://finnhub.io/api/v1/news?category=general&token=${apiKey}`);
    const data = await response.json();

    // Improved filter: remove placeholder or logo-only images
    const filteredNews = data.filter(article => {
      const img = article.image?.trim();
      return (
        img &&
        !img.includes("1.jpg") &&
        !img.includes("logo") &&
        !img.includes("marketwatch") &&
        !img.endsWith("/images-news/1.jpg")
      );
    });

    newsCarousel.innerHTML = "";

    filteredNews.slice(0, 6).forEach(article => {
      const card = document.createElement("div");
      card.className = "news-card";
      card.innerHTML = `
        <img src="${article.image}" alt="News image" />
        <a href="${article.url}" target="_blank">${article.headline}</a>
      `;
      newsCarousel.appendChild(card);
    });

  } catch (error) {
    console.error("Error fetching news:", error);
  }
}

fetchNews();



const finnhubApiKey = "d1cp2apr01qic6lf35s0d1cp2apr01qic6lf35sg";
const stocks = [
  { symbol: "NFLX", name: "netflix" },
  { symbol: "NKE", name: "nike" },
  { symbol: "AAPL", name: "apple" },
  { symbol: "AMZN", name: "amazon" }
];

async function fetchMarketMovers() {
  const fetches = stocks.map(stock =>
    fetch(`https://finnhub.io/api/v1/quote?symbol=${stock.symbol}&token=${finnhubApiKey}`)
      .then(res => res.json())
      .then(data => ({
        ...stock,
        change: data.dp
      }))
      .catch(err => {
        console.error(`Error fetching ${stock.symbol}:`, err);
        return null;
      })
  );

  const results = await Promise.all(fetches);

  results.forEach(result => {
    if (!result) return;

    const { name, symbol, change } = result;
    const el = document.getElementById(`${name}-change`);
    if (el) {
      el.textContent = `${change.toFixed(2)}%`;
      el.className = "percent " + (change >= 0 ? "positive" : "negative");
    }

    const card = document.querySelector(`[data-symbol="${symbol}"]`);
    if (card) {
      card.classList.remove("positive", "negative");
      card.classList.add(change >= 0 ? "positive" : "negative");
    }
  });
}

fetchMarketMovers();
setInterval(fetchMarketMovers, 30000);





const searchInput = document.getElementById("search-input");
const suggestionBox = document.getElementById("search-suggestions");
const finnhubKey = "d1cp2apr01qic6lf35s0d1cp2apr01qic6lf35sg";

searchInput.addEventListener("input", async () => {
  const query = searchInput.value.trim();

  if (query.length < 2) {
    suggestionBox.style.display = "none";
    return;
  }

  try {
    const res = await fetch(`https://finnhub.io/api/v1/search?q=${encodeURIComponent(query)}&token=${finnhubKey}`);
    const data = await res.json();

    suggestionBox.innerHTML = "";

    const results = data.result.slice(0, 10); // top 10 matches

    if (results.length === 0) {
      suggestionBox.style.display = "none";
      return;
    }

 results.forEach(async item => {
  const symbol = item.symbol;
  const type = item.type?.toLowerCase();
  let valid = false;

  // Check if it's a coin
  if (type === "crypto" || symbol.includes("/")) {
    // Call Coingecko to check if this coin exists and has chart data
    const coinId = symbol.toLowerCase().split("/")[0];
    try {
      const coinRes = await fetch(`https://api.coingecko.com/api/v3/coins/${coinId}`);
      if (coinRes.ok) {
        const coinData = await coinRes.json();
        if (coinData?.market_data?.current_price?.usd && coinData.image?.thumb) {
          valid = true;
        }
      }
    } catch (err) {
      console.log("Coin check failed:", symbol);
    }
  } else {
    // Check if it's a stock
    try {
      const stockRes = await fetch(`https://finnhub.io/api/v1/quote?symbol=${symbol}&token=${finnhubKey}`);
      if (stockRes.ok) {
        const stockData = await stockRes.json();
        if (stockData.c && stockData.c > 0) {
          valid = true;
        }
      }
    } catch (err) {
      console.log("Stock check failed:", symbol);
    }
  }

  if (valid) {
    const entry = document.createElement("div");
    entry.textContent = `${item.description} (${symbol})`;

    entry.addEventListener("click", () => {
      const cleanSymbol = symbol.includes("/") ? symbol.split("/")[0] : symbol;
      const typeFinal = (type === "crypto" || symbol.includes("/")) ? "coin" : "stock";
      window.location.href = `../detail.html?symbol=${cleanSymbol}&type=${typeFinal}`;
    });

    suggestionBox.appendChild(entry);
  }
});


    const rect = searchInput.getBoundingClientRect();
    suggestionBox.style.left = `${searchInput.offsetLeft}px`;
    suggestionBox.style.top = `${searchInput.offsetTop + searchInput.offsetHeight}px`;
    suggestionBox.style.display = "block";
  } catch (err) {
    console.error("Search error:", err);
    suggestionBox.style.display = "none";
  }
});

document.addEventListener("click", (e) => {
  if (!searchInput.contains(e.target) && !suggestionBox.contains(e.target)) {
    suggestionBox.style.display = "none";
  }
});

document.addEventListener("click", (e) => {
  const target = e.target.closest("[data-symbol]");
  if (!target) return;

  const symbol = target.getAttribute("data-symbol");
  const type = target.getAttribute("data-type");

  if (symbol && type) {
    window.location.href = `../detail.html?symbol=${encodeURIComponent(symbol)}&type=${type}`;
  }
});



