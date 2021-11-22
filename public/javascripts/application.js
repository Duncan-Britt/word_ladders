function toggleDarkMode() {
  document.body.classList.toggle("dark-mode");
  const nextStepElement = document.getElementById("next-step");
  if (nextStepElement) nextStepElement.focus();

  fetch('/toggle_dark_mode', {
    method: 'POST',
    // headers: {'Content-Type': 'application/json'},
    // body: JSON.stringify(''),
  }).then(res => {
    console.log("Request complete! response:", res);
  });
}


function lastStepIdx() {
  const list = document.getElementById("list");
  return Array.prototype.map.call(list.children, e => e.id.slice(-1))
                            .filter(id => /\d/.test(id))
                            .slice(-1)[0];
}

function validNextStep(nextStep) {
  const list = document.getElementById("list");
  const lastStep = document.getElementById(`step${lastStepIdx()}`).textContent;
  return oneLetterDifference(lastStep, nextStep);
}

function oneLetterDifference(word, other) {
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

function ladderIncludes(word) {
  const list = document.getElementById("list");
  const steps = Array.prototype.map.call(list.children, e => e.textContent);
  const prevSteps = steps.slice(0, -2);
  return prevSteps.includes(word);
}

function maxSteps() {
  return Number(document.getElementById('nSteps').textContent);
}

function isLastStep() {
  return Number(lastStepIdx()) === maxSteps() - 2
}

function lastStepStyle() {
  if (isLastStep()) {
    document.getElementById('final-step').setAttribute('class', 'code-font');
  } else {
    document.getElementById('final-step').removeAttribute('class');
  }
}
lastStepStyle();

function victoryStyle() {
  document.getElementById('final-step').setAttribute('class', 'victory');
}

function flashFigure(message, id) {
  const flashFigure = document.createElement("figure");
  flashFigure.setAttribute("id", id);
  flashFigure.setAttribute("class", "red-flash");
  const flashContent = document.createTextNode(message);
  flashFigure.appendChild(flashContent);
  return flashFigure;
}

// Driver Script

(function() {
  const form = document.getElementById("form");

  if (!form) {
    victoryStyle();
  }

  const inputStep = document.getElementById("next-step")
  form && form.addEventListener("submit", e => {
    if (ladderIncludes(inputStep.value)) {
      e.preventDefault();

      if (!document.getElementById("reuse-flash")) {
        const parent = inputStep.parentNode;
        parent.appendChild(flashFigure("Cannot reuse words", "reuse-flash"));
        setTimeout(() => {
          parent.removeChild(flashFigure)
        }, 8000);
      }
    } else if (!validNextStep(inputStep.value)) {
      e.preventDefault();


      if (!document.getElementById("unmatching-flash")) {
        const parent = inputStep.parentNode;
        parent.appendChild(flashFigure("Each subsequent word must only have one letter of difference from its predecessor", "unmatching-flash"));
        setTimeout(function(){
          parent.removeChild(flashFigure);
        }, 8000);
      }
    }
  });
}());

document.onclick = function() {
  const nextStepElement = document.getElementById("next-step");
  if (nextStepElement) nextStepElement.focus();
}

(function() {
  const checkbox = document.getElementById('checkbox');
  checkbox.addEventListener('change', toggleDarkMode);
}());


// DELETE STEP on empty input backspace
(function() {
  const nextStepElement = document.getElementById("next-step");
  if (nextStepElement) {
    nextStepElement.onkeydown = function() {
      const key = event.keyCode || event.charCode;
      if (key === 8) {
        if (document.forms["step"]["word"].value === '') {
          fetch('/step_back', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(''),
          }).then(res => {
            console.log("Request complete! response:", res);
          });

          const list = document.getElementById("list");
          const stepIdx = lastStepIdx();
          if (stepIdx !== '0') {
            const lastStep = document.getElementById(`step${stepIdx}`);
            lastStep.parentNode.removeChild(lastStep);
          }

          lastStepStyle();
        }
      }
    }
  }
}());
