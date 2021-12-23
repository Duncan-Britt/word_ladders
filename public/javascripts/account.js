document.addEventListener('DOMContentLoaded', () => {
  document.querySelector('#delete_account a').addEventListener('click', e => {
    e.preventDefault();

    renderAuthForm();
  });
});

function deleteAccount() {
  const xhr = new XMLHttpRequest();
  xhr.open('DELETE', '/account');
  xhr.addEventListener('load', () => {
    console.log(xhr.status);
    switch(xhr.status) {
      case 301:
        window.location = JSON.parse(xhr.response).path;
        break;
      case 401:
        document.querySelector('#frontendFlash').textContent = "Invalid credentials"
        break;
    }
  })
  xhr.send(new FormData(document.querySelector('#auth_form')));
}

function bindSubmitEvent() {
  document.querySelector('#auth_form').addEventListener('submit', e => {
    e.preventDefault();

    if (confirm(
      'Are you sure you want to delete your acccount? This can not be undone.'
    )) {
      deleteAccount();
    } else {
      document.querySelector('#auth_form').remove();
      document.querySelector('#frontendFlash').textContent = '';
    }
  });
}

function renderAuthForm() {
  if (document.querySelector('#auth_form')) return;

  document.querySelector('#delete_account p').insertAdjacentHTML('beforeend',
    `<form id="auth_form" action="/account" method="delete">
      <h1>Authenticate</h1>
      <fieldset>
        <p>
          <label for="loginUsername">username:</label>
          <input id="loginUsername" type="text" name="username" />
        </p>
        <p>
          <label for="loginPassword">password:</label>
          <input id="loginPassword" type="text" name="password" />
        </p>
        <p>
          <button type="submit">delete account</button>
        </p>
      </fieldset>
    </form>`
  )

  bindSubmitEvent();
}
