// profile.js

document.addEventListener("DOMContentLoaded", () => {
  const user = JSON.parse(localStorage.getItem("user"));

  if (!user) {
    alert("You are not logged in. Redirecting to login...");
    window.location.href = "login.html";
    return;
  }

  // Avatar and name
  const initials =
    user.username
      ?.split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase() || "U";
  document.querySelector(".profile-avatar").textContent = initials;
  document.querySelector(".profile-info h1").textContent =
    user.username || "Unknown";
  document.querySelector(".profile-info p").textContent = `@${
    user.username || "user"
  }`;

  // Safe balance & date fallback
  const balance = user.balance ?? 0;
  const createdAt = user.createdAt ?? null;

  animateBalance(Number(balance));

  document.querySelector(".value.join-date").textContent = createdAt
    ? new Date(createdAt).toLocaleDateString("en-US", {
        year: "numeric",
        month: "long",
        day: "numeric",
      })
    : "-";

  // Logout
  const logoutBtn = document.getElementById("logout-btn");
  if (logoutBtn) {
    logoutBtn.addEventListener("click", () => {
      localStorage.removeItem("user");
      window.location.href = "login.html";
    });
  }
});

// Animate sections one after another
const sections = document.querySelectorAll("section");
sections.forEach((sec, index) => {
  sec.style.opacity = 0;
  setTimeout(() => {
    sec.style.transition = "opacity 0.6s ease-out";
    sec.style.opacity = 1;
  }, index * 150);
});

//Add Animated Balance Counter

function animateBalance(targetValue, duration = 1500) {
  const balanceEl = document.querySelector(".value.balance");
  let start = 0;
  const startTime = performance.now();

  function update(currentTime) {
    const elapsed = currentTime - startTime;
    const progress = Math.min(elapsed / duration, 1);
    const current = Math.floor(progress * targetValue);

    balanceEl.textContent = `$${current.toLocaleString()}`;

    if (progress < 1) {
      requestAnimationFrame(update);
    } else {
      // Final exact value
      balanceEl.textContent = `$${targetValue.toLocaleString()}`;
    }
  }

  requestAnimationFrame(update);
}

// ripple buttons

document.querySelectorAll(".ripple-btn").forEach((btn) => {
  btn.addEventListener("click", function (e) {
    const circle = document.createElement("span");
    const diameter = Math.max(btn.clientWidth, btn.clientHeight);
    const radius = diameter / 2;

    circle.style.width = circle.style.height = `${diameter}px`;
    circle.style.left = `${
      e.clientX - btn.getBoundingClientRect().left - radius
    }px`;
    circle.style.top = `${
      e.clientY - btn.getBoundingClientRect().top - radius
    }px`;
    circle.classList.add("ripple");

    const ripple = btn.querySelector(".ripple");
    if (ripple) ripple.remove();

    circle.classList.add("ripple");
    btn.appendChild(circle);
  });
});
