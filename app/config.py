"""
Configuration management for HODLXXI.

Centralized environment variable loading and configuration.
"""
import os
from typing import Dict, Any


def get_config() -> Dict[str, Any]:
    """
    Load and return application configuration from environment variables.

    Returns:
        Dict containing all configuration values with sensible defaults.
    """
    return {
        # Bitcoin RPC Configuration
        "RPC_HOST": os.getenv("RPC_HOST", "127.0.0.1"),
        "RPC_PORT": int(os.getenv("RPC_PORT", "8332")),
        "RPC_USER": os.getenv("RPC_USER", "bitcoinrpc"),
        "RPC_PASSWORD": os.getenv("RPC_PASSWORD", "change-me"),
        "RPC_WALLET": os.getenv("RPC_WALLET", ""),

        # Flask Configuration
        "FLASK_SECRET_KEY": os.getenv("FLASK_SECRET_KEY", None),
        "FLASK_ENV": os.getenv("FLASK_ENV", "development"),
        "FLASK_DEBUG": os.getenv("FLASK_DEBUG", "0").lower() in ("1", "true", "yes"),

        # JWT Configuration
        "JWT_SECRET": os.getenv("JWT_SECRET", "dev-secret-CHANGE-ME-IN-PRODUCTION"),
        "JWT_ALGORITHM": os.getenv("JWT_ALGORITHM", "HS256"),
        "JWT_EXPIRATION_HOURS": int(os.getenv("JWT_EXPIRATION_HOURS", "24")),

        # LNURL Configuration
        "LNURL_BASE_URL": os.getenv("LNURL_BASE_URL", "http://localhost:5000"),

        # TURN Server Configuration (for WebRTC)
        "TURN_HOST": os.getenv("TURN_HOST", "turn.example.com"),
        "TURN_PORT": int(os.getenv("TURN_PORT", "3478")),
        "TURN_USER": os.getenv("TURN_USER", "user"),
        "TURN_PASS": os.getenv("TURN_PASS", "pass"),

        # CORS Configuration
        "CORS_ORIGINS": os.getenv("CORS_ORIGINS", "*"),
        "SOCKETIO_CORS": os.getenv("SOCKETIO_CORS", "*"),

        # Rate Limiting
        "RATE_LIMIT_ENABLED": os.getenv("RATE_LIMIT_ENABLED", "false").lower() in ("1", "true", "yes"),
        "RATE_LIMIT_DEFAULT": os.getenv("RATE_LIMIT_DEFAULT", "100/hour"),

        # Logging
        "LOG_LEVEL": os.getenv("LOG_LEVEL", "INFO"),
        "LOG_FILE": os.getenv("LOG_FILE", "logs/app.log"),

        # Database Configuration (for future use)
        "DATABASE_URL": os.getenv("DATABASE_URL", None),

        # Redis Configuration (for future use)
        "REDIS_HOST": os.getenv("REDIS_HOST", "localhost"),
        "REDIS_PORT": int(os.getenv("REDIS_PORT", "6379")),
        "REDIS_PASSWORD": os.getenv("REDIS_PASSWORD", None),
        "REDIS_DB": int(os.getenv("REDIS_DB", "0")),

        # Session Configuration
        "SESSION_LIFETIME_HOURS": int(os.getenv("SESSION_LIFETIME_HOURS", "24")),

        # Security Configuration
        "SECURE_COOKIES": os.getenv("SECURE_COOKIES", "false").lower() in ("1", "true", "yes"),
        "CSRF_ENABLED": os.getenv("CSRF_ENABLED", "false").lower() in ("1", "true", "yes"),

        # Application Settings
        "APP_NAME": os.getenv("APP_NAME", "HODLXXI"),
        "APP_VERSION": os.getenv("APP_VERSION", "1.0.0-alpha"),
        "APP_HOST": os.getenv("APP_HOST", "0.0.0.0"),
        "APP_PORT": int(os.getenv("APP_PORT", "5000")),
    }


def validate_config(config: Dict[str, Any]) -> bool:
    """
    Validate critical configuration values.

    Args:
        config: Configuration dictionary to validate

    Returns:
        True if configuration is valid, raises ValueError otherwise
    """
    # Check for insecure defaults in production
    if config["FLASK_ENV"] == "production":
        if config["JWT_SECRET"] == "dev-secret-CHANGE-ME-IN-PRODUCTION":
            raise ValueError("⚠️  JWT_SECRET must be changed for production!")

        if config["RPC_PASSWORD"] == "change-me":
            raise ValueError("⚠️  RPC_PASSWORD must be set for production!")

        if not config["FLASK_SECRET_KEY"]:
            raise ValueError("⚠️  FLASK_SECRET_KEY must be set for production!")

    return True
