// === Portfolio and Watchlist Script ===

// Sample data to simulate current portfolio and watchlist (normally fetched from API or DB)
const portfolioData = [
  {
    icon: "assets/icons/bitcoin.svg",
    name: "Bitcoin",
    symbol: "BTC",
    quantity: 2.6,
    avgCost: 86000,
    currentPrice: 84146.7,
    change: -2.15,
  },
  {
    icon: "assets/icons/tesla.png",
    name: "Tesla",
    symbol: "TSLA",
    quantity: 20,
    avgCost: 270,
    currentPrice: 277,
    change: 2.42,
  },
  {
    icon: "assets/icons/apple.png",
    name: "Apple",
    symbol: "AAPL",
    quantity: 29,
    avgCost: 320,
    currentPrice: 312,
    change: -2.25,
  },
];

let watchlist = [
  {
    icon: "assets/icons/tether.svg",
    name: "Tether",
    symbol: "TTR",
    currentPrice: 86.4,
    change: 1.21,
  },
  {
    icon: "assets/icons/netflix.png",
    name: "Netflix",
    symbol: "NFLX",
    currentPrice: 198.6,
    change: -4.21,
  },
  {
    icon: "assets/icons/amazon.png",
    name: "Amazon",
    symbol: "AMZN",
    currentPrice: 248.2,
    change: -2.71,
  },
];

function renderPortfolioTable() {
  const tableBody = document.querySelector("#portfolio-table-body");
  tableBody.innerHTML = "";

  portfolioData.forEach((asset) => {
    const totalValue = (asset.quantity * asset.currentPrice).toFixed(2);
    const row = document.createElement("tr");
    row.innerHTML = `
      <td><img src="${asset.icon}" alt="" /> ${asset.name}</td>
      <td>${asset.quantity}</td>
      <td>$${asset.avgCost.toLocaleString()}</td>
      <td>$${asset.currentPrice.toLocaleString()}</td>
      <td class="${
        asset.change >= 0 ? "positive" : "negative"
      }">${asset.change.toFixed(2)}%</td>
      <td>$${parseFloat(totalValue).toLocaleString()}</td>
    `;
    tableBody.appendChild(row);
  });
}

function renderWatchlistTable() {
  const tableBody = document.querySelector("#watchlist-table-body");
  tableBody.innerHTML = "";

  watchlist.forEach((asset, index) => {
    const row = document.createElement("tr");
    row.innerHTML = `
      <td><img src="${asset.icon}" alt="" /> ${asset.name}</td>
      <td>$${asset.currentPrice.toLocaleString()}</td>
      <td class="${
        asset.change >= 0 ? "positive" : "negative"
      }">${asset.change.toFixed(2)}%</td>
      <td><button class="btn btn-remove" onclick="removeFromWatchlist(${index})">Remove</button></td>
    `;
    tableBody.appendChild(row);
  });
}

function removeFromWatchlist(index) {
  watchlist.splice(index, 1);
  renderWatchlistTable();
}

window.addEventListener("DOMContentLoaded", () => {
  renderPortfolioTable();
  renderWatchlistTable();
});
