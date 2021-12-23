let CONSOLE;
// CONTENT LOADED
document.addEventListener("DOMContentLoaded", () => {
  // DOM ELEMENTS
  const darkModeToggler = document.getElementById('toggle-dark-mode-checkbox');

  // EVENTS
  darkModeToggler.addEventListener('change', toggleDarkMode);
});

// FUNCTIONS
function toggleDarkMode() {
  document.body.classList.toggle("dark-mode");
  const input = document.querySelector("#ladder input");
  if (input) input.focus();

  fetch('/toggle_dark_mode', {
    method: 'PUT',
  }).then(res => {
    // console.log("Request complete! response:", res);
  });
}
