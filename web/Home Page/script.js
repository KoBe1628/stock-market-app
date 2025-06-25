document.addEventListener('DOMContentLoaded', () => {
  const buyTab = document.querySelector('.buy');
  const sellTab = document.querySelector('.sell');
  const actionButton = document.querySelector('.submit-btn');
  const spendInput = document.getElementById('spend');
  const receiveInput = document.getElementById('receive');

  let mode = 'buy';
  let liveRate = 0.95; // fallback default

  // Fetch live USDC to EUR rate
  async function fetchExchangeRate() {
    try {
      const res = await fetch('https://api.coingecko.com/api/v3/simple/price?ids=usd-coin&vs_currencies=eur');
      const data = await res.json();
      if (data['usd-coin'] && data['usd-coin'].eur) {
        liveRate = data['usd-coin'].eur;
        updateReceive();
        updateRateDisplay();
      }
    } catch (err) {
      console.error("Error fetching exchange rate:", err);
    }
  }

  function updateRateDisplay() {
    const rateText = document.querySelector('.right-section p');
    if (rateText) {
      rateText.textContent = `Exchange Rate: 1 USDC ≈ ${liveRate.toFixed(4)} EUR`;
    }
  }

  function updateUI() {
    if (mode === 'buy') {
      buyTab.classList.add('active');
      sellTab.classList.remove('active');
      actionButton.textContent = 'Buy USDC';
      spendInput.placeholder = '10 - 10,000 EUR';
    } else {
      sellTab.classList.add('active');
      buyTab.classList.remove('active');
      actionButton.textContent = 'Sell USDC';
      spendInput.placeholder = '10 - 10,000 USDC';
    }
    updateReceive();
  }

  function updateReceive() {
    const amount = parseFloat(spendInput.value);
    if (!amount || amount <= 0) {
      receiveInput.value = '';
      return;
    }

    const receiveCurrency = mode === 'buy' ? 'USDC' : 'EUR';
    const result = mode === 'buy'
      ? (amount / liveRate).toFixed(2)
      : (amount * liveRate).toFixed(2);

    receiveInput.value = `${result} ${receiveCurrency}`;
  }

  buyTab.addEventListener('click', () => {
    mode = 'buy';
    updateUI();
  });

  sellTab.addEventListener('click', () => {
    mode = 'sell';
    updateUI();
  });

  spendInput.addEventListener('input', updateReceive);

  // Init
  fetchExchangeRate();
  updateUI();

  // Optional: update exchange rate every 60 seconds
  setInterval(fetchExchangeRate, 60000);
});


async function fetchCryptoPrices() {
  try {
    const res = await fetch('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,tether,dogecoin&vs_currencies=usd&include_24hr_change=true');
    const data = await res.json();

    updateCoin("btc", data.bitcoin.usd, data.bitcoin.usd_24h_change);
    updateCoin("eth", data.ethereum.usd, data.ethereum.usd_24h_change);
    updateCoin("usdt", data.tether.usd, data.tether.usd_24h_change);
    updateCoin("doge", data.dogecoin.usd, data.dogecoin.usd_24h_change);
  } catch (err) {
    console.error("Error fetching crypto data:", err);
  }
}

function updateCoin(idSuffix, price, change) {
  const priceEl = document.getElementById(`price-${idSuffix}`);
  const changeEl = document.getElementById(`change-${idSuffix}`);

  if (priceEl) priceEl.textContent = `$${price.toFixed(2)}`;
  if (changeEl) {
    const changeFormatted = `${change.toFixed(2)}%`;
    changeEl.textContent = changeFormatted;
    changeEl.className = change >= 0 ? "positive" : "negative";
  }
}

fetchCryptoPrices();
setInterval(fetchCryptoPrices, 30000); // every 30 sec
