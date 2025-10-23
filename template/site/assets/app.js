// Base script for Static Ruby
document.addEventListener('DOMContentLoaded', () => {
  const currentPath = window.location.pathname.replace(/\/$/, '') || '/';
  document
    .querySelectorAll('.layout__menu a')
    .forEach((link) => {
      const linkPath = link.getAttribute('href').replace(/\/$/, '') || '/';
      if (linkPath === currentPath) {
        link.classList.add('is-active');
      }
    });
});
