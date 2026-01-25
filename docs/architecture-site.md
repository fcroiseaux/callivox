# CalliVox Website - Architecture Documentation

**Part ID:** site
**Project Type:** Static Website
**Generated:** 2026-01-25

## Executive Summary

The CalliVox website is a static marketing landing page built on the "Dazzle" HTML template. It presents the CalliVox application features, pricing plans, and provides App Store download links. The site is entirely client-side with no backend requirements.

## Technology Stack

| Category | Technology | Purpose |
|----------|------------|---------|
| Markup | HTML5 | Page structure |
| Styling | CSS3 | Visual design |
| Interactivity | JavaScript (ES5) | User interactions |
| Library | jQuery 3.x | DOM manipulation |
| Animations | AOS | Scroll animations |
| Carousel | Owl Carousel | Testimonial slider |
| Template | Dazzle | Base HTML template |

## Architecture Pattern

**Style:** Static Site with jQuery Enhancements

```
┌─────────────────────────────────────────────┐
│              Static Assets                  │
│  (HTML, CSS, JavaScript, Images)            │
├─────────────────────────────────────────────┤
│              CDN Libraries                  │
│  (jQuery, AOS, Owl Carousel, Bootstrap)     │
├─────────────────────────────────────────────┤
│              Web Server                     │
│  (Static file serving)                      │
└─────────────────────────────────────────────┘
```

## File Structure

```
CalliVox-Site/
├── index.html          # Main landing page (French)
├── styles.html         # Template documentation
├── css/
│   └── main.css        # Primary stylesheet (2864 lines)
└── js/
    └── main.js         # jQuery interactions
```

## Page Sections

### index.html Structure

| Section ID | Purpose | Content |
|------------|---------|---------|
| `home` | Hero section | App introduction, download CTA |
| `about` | About section | Mission statement |
| `features` | Features | 6 key features with icons |
| `pricing` | Pricing plans | 2 plans (€120/year, €500 lifetime) |
| `testimonials` | Social proof | User testimonials carousel |
| `download` | Call to action | App Store links |

### Navigation

```html
<nav class="navbar">
  <ul>
    <li><a href="#home">Accueil</a></li>
    <li><a href="#about">À propos</a></li>
    <li><a href="#features">Fonctionnalités</a></li>
    <li><a href="#pricing">Tarifs</a></li>
    <li><a href="#testimonials">Témoignages</a></li>
    <li><a href="#download">Télécharger</a></li>
  </ul>
</nav>
```

## Styling System

### CSS Variables (Custom Properties)

```css
:root {
  --green: #ef5a49;  /* Primary accent (actually red/coral) */
  /* Additional variables defined in template */
}
```

### Responsive Breakpoints

| Breakpoint | Target |
|------------|--------|
| `max-width: 768px` | Tablet |
| `max-width: 480px` | Mobile |

### Key Style Classes

| Class | Purpose |
|-------|---------|
| `.section` | Page section container |
| `.btn-primary` | Primary call-to-action button |
| `.feature-box` | Feature item card |
| `.pricing-card` | Pricing plan card |
| `.navbar` | Navigation bar |

## JavaScript Functionality

### main.js Features

```javascript
$(document).ready(function() {
  // 1. Mobile menu toggle
  $('.menu-toggle').click(function() {
    $('.nav-menu').toggleClass('active');
  });

  // 2. Smooth scroll navigation
  $('a[href^="#"]').click(function(e) {
    e.preventDefault();
    $('html, body').animate({
      scrollTop: $($(this).attr('href')).offset().top
    }, 800);
  });

  // 3. Owl Carousel initialization
  $('.testimonial-carousel').owlCarousel({
    items: 1,
    loop: true,
    autoplay: true
  });

  // 4. AOS scroll animations
  AOS.init({
    duration: 1000,
    once: true
  });
});
```

### External Libraries

| Library | Version | CDN |
|---------|---------|-----|
| jQuery | 3.x | cdnjs |
| AOS | 2.x | cdnjs |
| Owl Carousel | 2.x | cdnjs |
| Bootstrap Icons | - | cdnjs |

## Content (French)

### Hero Section

- **Title:** "CalliVox"
- **Tagline:** Accessibility-focused text-to-speech
- **CTA:** "Télécharger sur l'App Store"

### Pricing Plans

| Plan | Price | Features |
|------|-------|----------|
| Annuel | €120/an | All features, 1 year access |
| À vie | €500 | All features, lifetime access |

### Features Highlighted

1. Text-to-speech conversion
2. Apple Pencil handwriting support
3. Predefined phrase shortcuts
4. High-quality AI voices (ElevenLabs)
5. Offline mode
6. Privacy-focused

## SEO Considerations

### Meta Tags

```html
<meta name="description" content="CalliVox - Application d'accessibilité pour personnes ayant des troubles de la parole">
<meta name="keywords" content="accessibilité, synthèse vocale, Apple Pencil, handicap">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

### Open Graph

```html
<meta property="og:title" content="CalliVox">
<meta property="og:description" content="...">
<meta property="og:image" content="...">
```

## Performance Considerations

- CSS minified for production
- Images optimized
- External libraries loaded from CDN
- Lazy loading for below-fold content
- AOS animations trigger on scroll

## Deployment

### Requirements

- Static file hosting (no server-side processing)
- HTTPS recommended for App Store links

### Compatible Hosting

- GitHub Pages
- Netlify
- Vercel
- AWS S3 + CloudFront
- Any static web server

## Browser Support

| Browser | Support |
|---------|---------|
| Chrome | Full |
| Safari | Full |
| Firefox | Full |
| Edge | Full |
| IE11 | Limited (jQuery polyfills) |
