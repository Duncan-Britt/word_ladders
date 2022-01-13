(function() {
  document.addEventListener("DOMContentLoaded", () => {
    setTimeout(deleteSuccessFlash, 10000);
    s('#unlock').addEventListener('click', e => {
      if (!confirm("Reveal solution?")) {
        e.preventDefault();
      }
    });

    // INIT
    reset();
  });

  let allowSubmission = true;

  function isLastStep() {
    return ladder.nUsrSteps == ladder.maxLength - 3;
  };

  let elements;
  let ladder;

  class Elements {
    constructor() {
      this.input = s('#ladder form input[name="step"]');
      this.form = s('#ladder form');
      this.ladder = s('#ladder');
      this.flashError = s('#backendFlash') || s('#frontendFlash');
      this.submitFired = false;
    }
  }

  class Ladder {
    constructor() {
      this.prev = prevSib(elements.ladder.querySelector('#input_li'), 'li').textContent;
      this.last = elements.ladder.querySelector('#input_li')
                          .nextElementSibling.textContent;
      this.maxLength = elements.ladder.dataset.length;
      this.nUsrSteps = elements.ladder.querySelector('ul').dataset.nUsrSteps;
    }
  }

  function reset() {
    elements = new Elements();
    ladder = new Ladder();
    elements.input.focus();

    bindEventListeners();
  }

  function bindEventListeners() {
    elements.input.addEventListener('keyup', typingHandler);
    elements.form.addEventListener('submit', submitStep);
  }

  function deletePreviousStep() {
    fetch('/step', { method: 'DELETE' }).then(async response => {
      if (response.status == 201) {
        delete ladder.prevInput;
        elements.ladder.innerHTML = await response.text();
        reset();
      }
    }).catch(error => {
      elements.flashError.textContent =
        "There seems to be a problem with your internet connection."
    });
  }

  function deleteSuccessFlash() {
    const flashSuccess = s('.flash-success');
    if (flashSuccess) flashSuccess.remove();
  }

  function typingHandler(e) {
    // DELETE FLASH ON BACKSPACE
    if (ladder.prevInput &&
        ladder.prevInput.length > elements.input.value.length) {

      if (elements.input.value.length > ladder.prev.length + 1) {
        elements.flashError.textContent =
          "The next step must be adjacent to the previous";
      } else {
        elements.flashError.innerHTML = '';
      }
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

    if (elements.input.value.length === ladder.prev.length + 1) {
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
    }

    if (elements.input.value.length > ladder.prev.length + 1) {
      elements.flashError.textContent =
        "The next step must be adjacent to the previous";
      elements.submitFired = false;
      return;
    }
  }

  function submitStep(event) {
    event.preventDefault();
    elements.submitFired = true;

    // PREVENT SUBMITING LAST STEP MULTIPLE TIMES
    if (allowSubmission !== true) return;

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

    // don't submit step again until response is found or timeout
    allowSubmission = false;
    setTimeout(() => {
      allowSubmission = true;
    }, 10000);

    fetch('/step', { method: 'POST', body: new FormData(elements.form) })
    .then(async response => {
      switch (response.status) {
        case 201:
          allowSubmission = true;
          delete ladder.prevInput;
          elements.ladder.innerHTML = await response.text();
          reset();
          break;
        case 204:
          allowSubmission = true;
          elements.flashError.textContent = "That word doesn't appear in our dictionary"
          elements.submitFired = false;
          break;
        case 301:
          window.location = await response.json().then(data => data.path);
          break;
      }
    }).catch(error => {
      elements.flashError.textContent =
        "There seems to be a problem with your internet connection."
    });
  }

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

  // GENERIC UTILITIES
  function s(selector) {
    return document.querySelector(selector);
  }

  function prevSib(element, selector) {
    const el = element.previousElementSibling;
    if (!el) return;

    return el.matches(selector) ? el : prevSib(el, selector);
  }
}());
