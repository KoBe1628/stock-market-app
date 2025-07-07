const STOCK_FALLBACKS = {
  AAPL: { name: "Apple", price: 213.55, change: 0.52 },
  AMZN: { name: "Amazon", price: 223.41, change: 1.56 },
};

const COIN_FALLBACKS = {
  BTC: { name: "Bitcoin", price: 88000, change: 1.25 },
};

document.addEventListener("DOMContentLoaded", () => {
  renderWatchlistTable();
});

function renderWatchlistTable() {
  const watchlist = JSON.parse(localStorage.getItem("watchlist")) || [];
  const tbody = document.querySelector("#watchlist-table-body");
  tbody.innerHTML = "";

  if (watchlist.length === 0) {
    const row = document.createElement("tr");
    row.innerHTML = `<td colspan="4" style="text-align:center;">No assets in watchlist.</td>`;
    tbody.appendChild(row);
    return;
  }

  watchlist.forEach((symbol) => {
    const fallback = STOCK_FALLBACKS[symbol] || COIN_FALLBACKS[symbol];
    if (!fallback) return;

    const { name, price, change } = fallback;
    const row = document.createElement("tr");
    row.innerHTML = `
      <td>${name}</td>
      <td>$${price.toFixed(2)}</td>
      <td style="color:${change >= 0 ? "green" : "red"};">${change.toFixed(
      2
    )}%</td>
      <td><button onclick="removeFromWatchlist('${symbol}')">Remove</button></td>
    `;
    tbody.appendChild(row);
  });
}

function removeFromWatchlist(symbol) {
  let list = JSON.parse(localStorage.getItem("watchlist")) || [];
  list = list.filter((item) => item !== symbol);
  localStorage.setItem("watchlist", JSON.stringify(list));
  renderWatchlistTable();
}
