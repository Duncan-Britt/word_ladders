document.addEventListener("DOMContentLoaded", () => {
  const elements = {};
  const ladder = {};

  // RESET DATA STRUCTURES
  const reset = () => {
    elements.input = document.querySelector('#ladder form input[name="step"]');
    elements.form = document.querySelector('#ladder form');
    elements.ladder = document.querySelector('#ladder');
    elements.flashError = document.querySelector('#backendFlash') ||
                     document.querySelector('#frontendFlash');
    elements.submitFired = false;

    ladder.prev = prevSib(elements.ladder.querySelector('#input_li'), 'li')
                    .textContent;
    ladder.last = elements.ladder.querySelector('#input_li')
                          .nextElementSibling.textContent;
    ladder.maxLength = elements.ladder.dataset.length;
    ladder.nUsrSteps = elements.ladder.querySelector('ul').dataset.nUsrSteps;
    elements.input.focus();
  }

  const isLastStep = () => {
    return ladder.nUsrSteps == ladder.maxLength - 3;
  };

  // NEW STEP SUBMISSION REQUEST
  const submitStep = () => {
    // VALIDATION
    if (!isAdjacent(ladder.prev, elements.input.value)) {
      elements.flashError.textContent =
        "The next step must be adjacent to the previous";
      elements.submitFired = false;
      return;
    }

    if (isLastStep()) {
      if (!isAdjacent(ladder.last, elements.input.value)) {
        elements.flashError.textContent =
          `The next step must be adjacent to "${ladder.last}"`;
        elements.submitFired = false;
        return;
      }
    }

    // REQUEST
    const xhr = new XMLHttpRequest();
    xhr.open('POST', '/step');
    xhr.addEventListener('load', _ => {
      console.log(xhr.status);
      if (xhr.status === 201) {
        delete ladder.prevInput;
        elements.ladder.innerHTML = xhr.response;
        reset();
        bind();
      } else if (xhr.status === 204) {
          elements.flashError.textContent = "That word doesn't appear in our dictionary"
          elements.submitFired = false;
      } else if (xhr.status === 301) {
        window.location = JSON.parse(xhr.response).path;
      }
    });
    xhr.send(new FormData(elements.form));
  }

  const deletePreviousStep = () => {
    const xhr = new XMLHttpRequest();
    xhr.open('DELETE', '/step');
    xhr.addEventListener('load', _ => {
      console.log(xhr.status);
      if (xhr.status === 201) {
        delete ladder.prevInput;
        elements.ladder.innerHTML = xhr.response;
        reset();
        bind();
      }
    });
    xhr.send();
  }

  // BIND EVENT HANDLERS
  function bind() {
    elements.input.addEventListener('keyup', e => {
      // DELETE FLASH ON BACKSPACE
      if (ladder.prevInput &&
          ladder.prevInput.length > elements.input.value.length) {
        elements.flashError.innerHTML = '';
      }

      // DELETE PREVIOUS STEP ON EMPTY BACKSPACE
      if (ladder.hasOwnProperty('prevInput') &&
          !ladder.prevInput &&
          !elements.submitFired &&
          elements.input.value.length <= ladder.prevInput.length) {

        deletePreviousStep();
        return;
      }

      elements.input.value = elements.input.value.toLowerCase();
      ladder.prevInput = elements.input.value;

      if (isLastStep() && isAdjacent(elements.input.value, ladder.last)) {
        submitStep();
        return
      }

      if (elements.input.value.length === ladder.prev.length + 1) {
        submitStep();
      }
    });

    elements.form.addEventListener('submit', e => {
      e.preventDefault();
      elements.submitFired = true;
      submitStep();
    });
  }

  // INITIALZE DATA STRUCTURES
  reset();

  // BIND EVENT HANDLERS
  bind();
});

// touchstart
// touchsnd
// touchmove
// touchcancel

// HELPER FUNCTIONS
function isAdjacent(word, other) {
  if (word.length === other.length) {
    let differentChrCount = 0;
    for (let i = 0; i < word.length; i++) {
      if (word[i] !== other[i]) differentChrCount++;
      if (differentChrCount > 1) return false;
    }

    return differentChrCount === 1;
  } else if (word.length === other.length + 1) {
    let i = 0;
    let j = 0;
    while (word[i] === other[j] && i < word.length) {
      i++;
      j++;
    }
    i++;

    while (i < word.length) {
      if (word[i++] !== other[j++]) return false;
    }

    return true;
  } else if (other.length === word.length + 1){
    let i = 0;
    let j = 0;
    while (word[i] === other[j] && i < word.length) {
      i++;
      j++;
    }
    j++;

    while (j < other.length) {
      if (word[i++] !== other[j++]) return false;
    }

    return true;
  } else {
    return false;
  }
}

function prevSib(element, selector) {
  const el = element.previousElementSibling;
  if (!el) return;

  return el.matches(selector) ? el : prevSib(el, selector);
}