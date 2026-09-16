async function loadFaqs() {
  const list = document.getElementById('faq-list');
  const empty = document.getElementById('empty-state');

  try {
    const res = await fetch('/api/faqs');
    const data = await res.json();

    if (!data.faqs || data.faqs.length === 0) {
      empty.style.display = '';
      return;
    }

    data.faqs.forEach(faq => {
      const article = document.createElement('article');
      article.className = 'faq-item';
      article.innerHTML = `
        <span class="faq-category">${faq.category}</span>
        <p class="faq-question">${faq.question}</p>
        <p class="faq-answer">${faq.answer}</p>
      `;
      list.appendChild(article);
    });
  } catch (err) {
    empty.textContent = 'Could not load FAQs. The backend may be unavailable.';
    empty.style.display = '';
  }
}

loadFaqs();
