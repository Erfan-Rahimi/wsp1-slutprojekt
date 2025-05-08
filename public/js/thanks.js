
const message = "Tack för ditt köp!";
    let i = 0;

    setTimeout(() => {
      document.getElementById('spinner').style.display = 'none';
      const msgEl = document.getElementById('thanks-message');

      const interval = setInterval(() => {
        msgEl.textContent += message[i];
        i++;
        if (i >= message.length) {
          clearInterval(interval);
          setTimeout(() => {
            window.location.href = "/products/index";
          }, 1500);
        }
      }, 120);
    }, 1500);