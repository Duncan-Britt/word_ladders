document.addEventListener('DOMContentLoaded', () => {
  const form = document.querySelector('form');
  form.addEventListener('submit', e => {
    e.preventDefault();
    xhr = new XMLHttpRequest();
    xhr.open('PUT', '/username');
    xhr.addEventListener('load', _ => {
      if (xhr.status === 204) {
        window.location.href = "/account";
      } else if (xhr.status === 403) {
        console.log(xhr.response);
        flashMessage = document.querySelector('#flash-error')
        flashMessage.style.visibility = "visible";
        flashMessage.textContent = xhr.response;
      }
    });
    xhr.send(new FormData(form));
  })
});
