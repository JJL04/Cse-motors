# CSE Motors — Assignment 1

A responsive car dealership website built with Express.js and EJS, featuring a mobile-first design, contact form with validation, and automated tests.

## Local Development

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start the development server:
   ```bash
   npm run dev
   ```

3. View the site at http://localhost:3000

4. Run tests:
   ```bash
   npm test
   ```

## Deployment to Render.com

1. Create a new Web Service on render.com
2. Connect to your GitHub repository
3. Use these settings:
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Node Version**: 18.x (or your preferred version)
   - **Environment Variables**: None required

The `Procfile` is already configured for Render deployment.

## Features

- Mobile-first responsive design
- Professional fonts and WCAG-compliant color scheme
- Server-side form validation
- JSON-based inquiry storage
- EJS templating with layouts and partials
- Automated tests for routes and validation

## Structure

```
.
├── data/               # JSON data store
├── public/            
│   ├── css/           # Stylesheets
│   └── images/        # Site images
├── views/
│   ├── layouts/       # EJS layouts
│   ├── partials/      # Header, footer, etc.
│   └── index.ejs      # Home view
├── __tests__/         # Test suite
├── server.js          # Express application
└── package.json       # Dependencies
```

## Testing

The test suite validates:
- Home page rendering
- Contact form submission
- Input validation
- Error handling

Run tests with:
```bash
npm test
```
