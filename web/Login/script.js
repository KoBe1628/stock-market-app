// script.js - for Login page
document.querySelector('.login-form').addEventListener('submit', function (e) {
  e.preventDefault();

  const emailOrUsername = e.target[0].value;
  const password = e.target[1].value;

  const storedUser = JSON.parse(localStorage.getItem('user'));

  if (
    storedUser &&
    (storedUser.email === emailOrUsername || storedUser.username === emailOrUsername) &&
    storedUser.password === password
  ) {
    alert('Login successful!');
    window.location.href = '../Main Page/homepage.html'; // Change to your actual home file
  } else {
    alert('Invalid credentials. Please try again.');
  }
});
