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

const form = document.getElementById("form");

if (!form) {
  victoryStyle();
}

const nextStep = document.getElementById("next-step")
form && form.addEventListener("submit", e => {
  if (ladderIncludes(nextStep.value)) {
    e.preventDefault();
    // console.log('stopped submission!');
    // create flash message
    if (!document.getElementById("reuse-flash")) {
      const flashFigure = document.createElement("figure")
      flashFigure.setAttribute("id", "reuse-flash");
      flashFigure.setAttribute("class", "red-flash");
      const flashContent = document.createTextNode("Cannot reuse words");
      flashFigure.appendChild(flashContent);
      const parent = nextStep.parentNode;
      parent.appendChild(flashFigure);
      setTimeout(() => {
        parent.removeChild(flashFigure)
      }, 8000);
    }
  } else if (!validNextStep(nextStep.value)) {
    e.preventDefault();
    // console.log('stopped submission!');
    // create flash message
    if (!document.getElementById("unmatching-flash")) {
      const flashFigure = document.createElement("figure")
      flashFigure.setAttribute("id", "unmatching-flash");
      flashFigure.setAttribute("class", "red-flash");
      const flashContent = document.createTextNode("Each subsequent word must only have one letter of difference between it and the last");
      flashFigure.appendChild(flashContent);
      const parent = nextStep.parentNode;
      parent.appendChild(flashFigure);
      setTimeout(function(){
        parent.removeChild(flashFigure);
      }, 8000);
    }
  } 
});


function ladderIncludes(word) {
  const list = document.getElementById("list");
  const steps = Array.prototype.map.call(list.children, e => e.textContent);
  const prevSteps = steps.slice(0, -2);
  return prevSteps.includes(word);
}

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

document.onclick = function() {
  const nextStepElement = document.getElementById("next-step");
  if (nextStepElement) nextStepElement.focus();
}

const checkbox = document.getElementById('checkbox');
checkbox.addEventListener('change', toggleDarkMode);

// delete step on empty input backspace
const nextStepElement = document.getElementById("next-step");
if (nextStepElement) {
  nextStepElement.onkeydown = function() {
    const key = event.keyCode || event.charCode;
    if (key === 8) {
      if (document.forms["step"]["word"].value === '') {
        // let xhr = new XMLHttpRequest();
        // xhr.open("POST", "/step_back", true);
        // xhr.setRequestHeader('Content-Type', 'application/json');
        // xhr.send(JSON.stringify({
        //     value: null,
        // }));
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

function lastStepIdx() {
  const list = document.getElementById("list");
  return Array.prototype.map.call(list.children, e => e.id.slice(-1))
                            .filter(id => /\d/.test(id))
                            .slice(-1)[0];
}
