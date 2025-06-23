<button onclick = "window.location.href = '' " > Already have an account? Log in  </button>

document.querySelector(".login-form").addEventListener("submit", async function (e) {
  e.preventDefault();

  const username = document.querySelector("input[placeholder='Username']").value;
  const email = document.querySelector("input[placeholder='Email Address']").value;
  const password = document.querySelector("input[placeholder='Password']").value;
  const confirmPassword = document.querySelector("input[placeholder='Confirm Password']").value;

  if (password !== confirmPassword) {
    alert("Passwords do not match.");
    return;
  }

  try {
    const response = await fetch("https://stocks-backend-9lwx.onrender.com/register", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, email, password }),
    });

    const result = await response.json();

    if (response.ok) {
      alert("Registration successful!");
      // Optionally redirect to login
    } else {
      alert(result.message || "Registration failed.");
    }
  } catch (error) {
    alert("Error connecting to server.");
  }
});
