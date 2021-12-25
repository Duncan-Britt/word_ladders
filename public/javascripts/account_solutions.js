(function() {
  function pageReadyHandler(solutions) {
    ScrollManager.init(solutions);
  }

  const ScrollManager = {
    init(solutions) {
      this.xhrQueryWindowSize = solutions.length;

      this.offset = solutions.length;
      this.compileToHTML(solutions)
      document.querySelector('main').insertAdjacentHTML('beforeend', this.html);

      document.addEventListener('scroll', e => {
        if (!this.scrollFired && document.body.scrollHeight - pageYOffset < 10000) {
          this.scrollFired = true;
          this.loadAndRenderData();
        }
      });
    },

    compileToHTML(solutions) {
      let html = '';
      solutions.forEach(puzzle => {
        let partial = `<div class="solution">
          <h1>From <span class="print">${puzzle.first}</span> to <span class="print">${puzzle.last}</span> in <span class="print">${puzzle.length - 1}</span> steps or fewer</h1>
          <ul>`

        puzzle.solution.forEach(step => {
          partial += `<li>${step}</li>`
        });

        partial += `</ul>
        </div>`

        html += partial
      });

      this.html = html;
    },

    loadAndRenderData() {
      const xhr = new XMLHttpRequest();
      xhr.open('GET', '/account/solutions/' + this.offset);
      xhr.responseType = 'json';
      xhr.addEventListener('load', () => {
        if (xhr.response.length === 0) return;

        this.compileToHTML(xhr.response);
        document.querySelector('main')
                .insertAdjacentHTML('beforeend', this.html);

        this.scrollFired = false;
      });
      xhr.send();
      this.offset += this.xhrQueryWindowSize;
    },
  };

  // LOAD INITIAL SOLUTIONS, CALL READY HANDLER WHEN BOTH DOM AND SOLUTIONS LOADED
  let domLoaded = false;
  let solutionsLoaded = false;

  const xhr = new XMLHttpRequest();
  xhr.open('GET', '/account/solutions/0');
  xhr.responseType = 'json';
  xhr.addEventListener('load', () => {
    if (domLoaded) {
      pageReadyHandler(xhr.response);
    } else {
      solutionsLoaded = true;
    }
  });
  xhr.send();

  document.addEventListener('DOMContentLoaded', e => {
    if (solutionsLoaded) {
      pageReadyHandler(xhr.response);
    } else {
      domLoaded = true;
    }
  });
}());
