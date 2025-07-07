// script.js - for Sign Up page
document.querySelector(".login-form").addEventListener("submit", function (e) {
  e.preventDefault();

  const username = e.target[0].value;
  const email = e.target[1].value;
  const password = e.target[2].value;
  const confirmPassword = e.target[3].value;

  if (password !== confirmPassword) {
    alert("Passwords do not match!");
    return;
  }

  const newUser = {
    username,
    email,
    password,
    balance: 10000.0,
    createdAt: new Date().toISOString(),
  };

  localStorage.setItem("user", JSON.stringify(newUser));
  alert("Registration successful! Redirecting to home...");
  window.location.href = "home.html";
});
