document.querySelector (".login-form").addEventListener("submit", function (e) {
    e.preventDefault();

    alert("Login successful!");

});

<button onclick = "window.location.href = '' " > Create new account </button>


document.querySelector(".login-form").addEventListener("submit", async function (e) {
  e.preventDefault();

  const emailOrUsername = document.querySelector("input[type='text']").value;
  const password = document.querySelector("input[type='password']").value;

  try {
    const response = await fetch("https://stocks-backend-9lwx.onrender.com/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        username: emailOrUsername,
        password: password
      }),
    });

    const result = await response.json();

    if (response.ok) {
      alert("Login successful!");
      // Redirect or store token if needed
    } else {
      alert(result.message || "Login failed.");
    }
  } catch (error) {
    alert("Error connecting to server.");
  }
});
