(function() {
  document.addEventListener("DOMContentLoaded", () => {
    const darkModeToggler = document.getElementById('toggle-dark-mode-checkbox');

    darkModeToggler.addEventListener('change', toggleDarkMode);
  });

  function toggleDarkMode() {
    document.body.classList.toggle("dark-mode");
    const input = document.querySelector("#ladder input");
    if (input) input.focus();

    fetch('/toggle_dark_mode', { method: 'PUT' });
  }
}());
