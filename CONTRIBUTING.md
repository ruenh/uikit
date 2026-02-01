# Contributing to TMA Studio

Thank you for your interest in contributing to TMA Studio! This document provides guidelines and instructions for contributing.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/uikit.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test thoroughly
6. Submit a pull request

## Development Setup

See the [README.md](README.md) for detailed setup instructions.

Quick start:
```bash
# Install dependencies
cd apps/web && npm install
cd ../api && pip install -r requirements.txt
cd ../bot && pip install -r requirements.txt

# Run services
npm run dev          # Web app
uvicorn app.main:app --reload  # API
python bot.py        # Bot
```

## Code Style

- **JavaScript/TypeScript**: Follow existing code style
- **Python**: Follow PEP 8
- **Commits**: Use clear, descriptive commit messages

## Testing

Before submitting a PR:

1. Run the smoke test (see README.md)
2. Test in Telegram (not just browser)
3. Verify no console errors
4. Check that authentication works
5. Verify preferences persist

## Pull Request Process

1. Update documentation if needed
2. Add/update tests (Phase 2+)
3. Ensure all checks pass
4. Request review from maintainers
5. Address review feedback

## Security

Never commit:
- `.env` files
- API keys or tokens
- Passwords or secrets
- Personal data

## Questions?

Open an issue for questions or discussions.
