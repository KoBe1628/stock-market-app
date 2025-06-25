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
