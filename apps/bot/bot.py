"""
TMA Studio - Telegram Bot

This bot launches the TMA Studio Mini App when users send /start command.
Uses aiogram 3.x framework with proper error handling and logging.
"""

import asyncio
import logging
import sys
from os import getenv

from dotenv import load_dotenv
from aiogram import Bot, Dispatcher
from aiogram.client.default import DefaultBotProperties
from aiogram.enums import ParseMode
from aiogram.filters import CommandStart
from aiogram.types import Message, InlineKeyboardMarkup, InlineKeyboardButton, WebAppInfo


# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stdout
)
logger = logging.getLogger(__name__)


# Load environment variables from .env file
# Source: python-dotenv documentation
# Verified: load_dotenv() loads .env file from current directory
load_dotenv()


def validate_environment() -> tuple[str, str]:
    """
    Validate required environment variables.
    
    Returns:
        Tuple of (BOT_TOKEN, WEB_APP_URL)
    
    Raises:
        ValueError: If required environment variables are missing
    """
    bot_token = getenv("BOT_TOKEN")
    web_app_url = getenv("WEB_APP_URL")
    
    if not bot_token:
        raise ValueError("BOT_TOKEN environment variable is required")
    
    if not web_app_url:
        raise ValueError("WEB_APP_URL environment variable is required")
    
    logger.info("Environment variables validated successfully")
    logger.info(f"Web App URL: {web_app_url}")
    
    return bot_token, web_app_url


# Validate environment on module load
try:
    BOT_TOKEN, WEB_APP_URL = validate_environment()
except ValueError as e:
    logger.error(f"Environment validation failed: {e}")
    logger.error("Please set BOT_TOKEN and WEB_APP_URL in .env file")
    sys.exit(1)


# Initialize Dispatcher
dp = Dispatcher()


@dp.message(CommandStart())
async def command_start_handler(message: Message) -> None:
    """
    Handle /start command.
    
    Sends a welcome message with an inline keyboard button that opens the Mini App.
    
    Requirements:
    - 11.2: Respond to /start command with welcome message
    - 11.3: Provide inline keyboard button with web_app parameter
    """
    try:
        # Get user's first name for personalized greeting
        user_name = message.from_user.first_name if message.from_user else "there"
        
        # Create inline keyboard with WebApp button
        # Source: aiogram 3.x documentation - InlineKeyboardButton with web_app parameter
        # Verified: web_app takes WebAppInfo(url=...) to launch Mini App
        keyboard = InlineKeyboardMarkup(
            inline_keyboard=[
                [
                    InlineKeyboardButton(
                        text="🚀 Open TMA Studio",
                        web_app=WebAppInfo(url=WEB_APP_URL)
                    )
                ]
            ]
        )
        
        # Send welcome message with keyboard
        welcome_text = (
            f"👋 Hello, {user_name}!\n\n"
            "Welcome to <b>TMA Studio</b> — a premium Telegram Mini App showcase.\n\n"
            "Experience:\n"
            "• Premium design with modern UI\n"
            "• Telegram-native integrations\n"
            "• Smooth animations and transitions\n"
            "• Theme customization\n\n"
            "Click the button below to launch the app! 👇"
        )
        
        await message.answer(
            text=welcome_text,
            reply_markup=keyboard,
            parse_mode=ParseMode.HTML
        )
        
        logger.info(
            f"Sent welcome message to user {message.from_user.id} "
            f"(@{message.from_user.username or 'no_username'})"
        )
        
    except Exception as e:
        logger.error(f"Error in start command handler: {e}", exc_info=True)
        
        # Send fallback message to user
        try:
            await message.answer(
                "Sorry, something went wrong. Please try again later.",
                parse_mode=ParseMode.HTML
            )
        except Exception as fallback_error:
            logger.error(f"Failed to send error message: {fallback_error}")


async def main() -> None:
    """
    Main function to initialize bot and start polling.
    
    Requirements:
    - 11.1: Use aiogram 3.x framework
    - 11.4: Use BOT_TOKEN from environment variables
    - 11.5: Handle errors gracefully and log failures
    """
    try:
        # Initialize Bot instance with default properties
        # Source: aiogram 3.x documentation - Bot initialization
        # Verified: DefaultBotProperties sets parse_mode for all API calls
        bot = Bot(
            token=BOT_TOKEN,
            default=DefaultBotProperties(parse_mode=ParseMode.HTML)
        )
        
        logger.info("Bot initialized successfully")
        logger.info("Starting polling...")
        
        # Start polling for updates
        # Source: aiogram 3.x documentation - Dispatcher.start_polling()
        # Verified: start_polling() is the recommended method for long-polling
        await dp.start_polling(bot)
        
    except Exception as e:
        logger.error(f"Fatal error in main: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Bot stopped by user")
    except Exception as e:
        logger.error(f"Unexpected error: {e}", exc_info=True)
        sys.exit(1)
