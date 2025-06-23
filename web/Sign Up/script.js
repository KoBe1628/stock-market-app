// script.js - for Sign Up page
document.querySelector('.login-form').addEventListener('submit', function (e) {
  e.preventDefault();

  const username = e.target[0].value;
  const email = e.target[1].value;
  const password = e.target[2].value;
  const confirmPassword = e.target[3].value;

  if (password !== confirmPassword) {
    alert('Passwords do not match!');
    return;
  }

  // Save user to localStorage
  localStorage.setItem('user', JSON.stringify({ username, email, password }));
  alert('Registration successful! Redirecting to login...');
  window.location.href = '../Login/login.html';
});
