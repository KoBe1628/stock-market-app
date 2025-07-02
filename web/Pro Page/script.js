document.addEventListener("DOMContentLoaded", function () {
  const pricingButtons = document.querySelectorAll(".pricing-button");

  pricingButtons.forEach((btn) => {
    btn.addEventListener("click", () => {
      pricingButtons.forEach((b) => b.classList.remove("selected"));
      btn.classList.add("selected");
    });
  });
});

document.addEventListener("DOMContentLoaded", () => {
    const currentPage = document.body.dataset.page;
    const navLinks = document.querySelectorAll('.nav-links a');

    navLinks.forEach(link => {
      const href = link.getAttribute('href') || '';
      // Match based on known href parts and the page label
      if (
        (currentPage === "home" && href.includes("Main Page/homepage.html")) ||
        (currentPage === "buy" && href.includes("Home Page/homepage.html")) ||
        (currentPage === "pro" && href.includes("Pro Page/propage.html")) ||
        (currentPage === "portfolio" && href.includes("portfolio")) ||
        (currentPage === "profile" && href.includes("profile"))
      ) {
        link.classList.add("active-page");
      }
    });
  });
