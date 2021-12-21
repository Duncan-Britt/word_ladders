document.addEventListener('DOMContentLoaded', () => {
  const form = document.querySelector('form');
  form.addEventListener('submit', e => {
    e.preventDefault();
    xhr = new XMLHttpRequest();
    xhr.open('PUT', '/password');
    xhr.addEventListener('load', _ => {
      if (xhr.status === 204) {
        window.location.href = "/account";
      }
    });
    xhr.send(new FormData(form));
  })
});
