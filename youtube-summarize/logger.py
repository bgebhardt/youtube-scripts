#!/usr/bin/env python3
"""
Logging utility for YouTube summarizer scripts.
"""

import sys
from typing import Optional

class Logger:
    def __init__(self, verbose: bool = True):
        self.verbose = verbose
        
    def info(self, message: str) -> None:
        """Log info message - only shown in verbose mode."""
        if self.verbose:
            print(f"[INFO] {message}", file=sys.stdout)
    
    def warning(self, message: str) -> None:
        """Log warning message - always shown."""
        print(f"[WARNING] {message}", file=sys.stdout)
    
    def error(self, message: str) -> None:
        """Log error message - always shown."""
        print(f"[ERROR] {message}", file=sys.stdout)
    
    def output(self, message: str) -> None:
        """Log output message - always shown (for final results)."""
        print(message, file=sys.stdout)

# Global logger instance
_logger: Optional[Logger] = None

def init_logger(verbose: bool = True) -> None:
    """Initialize the global logger with verbosity setting."""
    global _logger
    _logger = Logger(verbose)

def get_logger() -> Logger:
    """Get the global logger instance."""
    global _logger
    if _logger is None:
        _logger = Logger(verbose=True)  # Default to verbose
    return _logger

# Convenience functions
def log_info(message: str) -> None:
    """Log info message."""
    get_logger().info(message)

def log_warning(message: str) -> None:
    """Log warning message."""
    get_logger().warning(message)

def log_error(message: str) -> None:
    """Log error message."""
    get_logger().error(message)

def log_output(message: str) -> None:
    """Log output message."""
    get_logger().output(message)