const SEARCH_API_KEY = "d1d6or1r01qic6lhho80d1d6or1r01qic6lhho8g";
const searchInput = document.getElementById("search-input");
const dropdown = document.getElementById("search-dropdown");
let debounceTimeout;

console.log("Header JS loaded!");

if (searchInput && dropdown) {
  searchInput.addEventListener("input", () => {
    const query = searchInput.value.trim();
    if (debounceTimeout) clearTimeout(debounceTimeout);

    if (query.length === 0) {
      dropdown.innerHTML = "";
      dropdown.style.display = "none";
      return;
    }

    debounceTimeout = setTimeout(() => fetchSuggestions(query), 300);
  });

  document.addEventListener("click", (e) => {
    if (!document.querySelector(".search-wrapper").contains(e.target)) {
      dropdown.style.display = "none";
    }
  });
}

async function fetchSuggestions(query) {
  try {
    const res = await fetch(
      `https://finnhub.io/api/v1/search?q=${query}&token=${SEARCH_API_KEY}`
    );
    const data = await res.json();
    renderSuggestions(data.result.slice(0, 5));
  } catch (err) {
    console.error("Search error:", err);
    dropdown.innerHTML = "<li>Error fetching suggestions</li>";
    dropdown.style.display = "block";
  }
}

function renderSuggestions(suggestions) {
  if (!suggestions.length) {
    dropdown.innerHTML = "<li>No results found</li>";
  } else {
    dropdown.innerHTML = suggestions
      .map(
        (item) => `
        <li>
          <a href="detail.html?symbol=${item.symbol}">
            <strong>${item.symbol}</strong> — ${item.description}
          </a>
        </li>`
      )
      .join("");
  }
  dropdown.style.display = "block";
}

function handleSuggestionClick(symbol) {
  window.location.href = `detail.html?symbol=${symbol}&type=stock`;
}

let activeIndex = -1;

searchInput.addEventListener("keydown", (e) => {
  const items = dropdown.querySelectorAll("li");

  if (!items.length) return;

  if (e.key === "ArrowDown") {
    e.preventDefault();
    activeIndex = (activeIndex + 1) % items.length;
    updateActiveItem(items);
  } else if (e.key === "ArrowUp") {
    e.preventDefault();
    activeIndex = (activeIndex - 1 + items.length) % items.length;
    updateActiveItem(items);
  } else if (e.key === "Enter" && activeIndex >= 0) {
    e.preventDefault();
    items[activeIndex].click();
  } else if (e.key === "Escape") {
    dropdown.style.display = "none";
    activeIndex = -1;
  }
});

function updateActiveItem(items) {
  items.forEach((item, index) => {
    if (index === activeIndex) {
      item.classList.add("active");
      item.scrollIntoView({ block: "nearest" });
    } else {
      item.classList.remove("active");
    }
  });
}

document.addEventListener("click", (e) => {
  const wrapper = document.querySelector(".search-wrapper");
  if (!wrapper.contains(e.target)) {
    dropdown.style.display = "none";
    currentIndex = -1;
  }
});
