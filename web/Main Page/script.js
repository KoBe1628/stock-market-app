const apiKey = "d1cp2apr01qic6lf35s0d1cp2apr01qic6lf35sg";
const newsCarousel = document.getElementById("news-carousel");

async function fetchNews() {
  try {
    const response = await fetch(`https://finnhub.io/api/v1/news?category=general&token=${apiKey}`);
    const data = await response.json();

    data.slice(0, 6).forEach(article => {
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
