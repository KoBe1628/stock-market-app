document.addEventListener('DOMContentLoaded', () => {
  const buyTab = document.querySelector('.buy');
  const sellTab = document.querySelector('.sell');
  const actionButton = document.querySelector('.submit-btn');
  const spendInput = document.getElementById('spend');
  const receiveInput = document.getElementById('receive');

  let mode = 'buy';
  const rate = 0.95;

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
      ? (amount / rate).toFixed(2)
      : (amount * rate).toFixed(2);

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
  updateUI();
});
