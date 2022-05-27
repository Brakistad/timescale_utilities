import gunicorn

gunicorn.SERVER_SOFTWARE = "Python"

# Override logging to standardize the output
logconfig_dict = {
    "version": 1,
    "disable_existing_loggers": True,
    "formatters": {
        "default": {
            "()": "logging.Formatter",
            "fmt": "[%(asctime)s] [%(process)d] [%(levelname)s] [%(module)s.%(funcName)s] [%(filename)s:%(lineno)d] [%(name)s] %(message)s",
            # Use ISO 8601 format for datetime, with added microseconds
            "datefmt": "%Y-%m-%d %H:%M:%S %z",
        },
        "access": {
            "()": "logging.Formatter",
            "fmt": '[%(asctime)s] [%(process)d] [%(levelname)s] %(client_addr)s - "%(request_line)s" %(status_code)s',  # noqa: E501
            "datefmt": "%Y-%m-%d %H:%M:%S %z",
        },
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "default",
            "level": "INFO",
            "stream": "ext://sys.stdout",
        },
        "error_console": {
            "class": "logging.StreamHandler",
            "formatter": "default",
            "stream": "ext://sys.stderr",
        },
        "access": {
            "formatter": "access",
            "class": "logging.StreamHandler",
            "stream": "ext://sys.stdout",
        },
    },
    "loggers": {
        "gunicorn": {
            "handlers": ["console"],
            "level": "INFO",
        },
        "gunicorn.error": {
            "propagate": True,
            "level": "INFO",
        },
        "gunicorn.access": {
            "handlers": ["access"],
            "level": "INFO",
            "propagate": False,
        },
    },
    "root": {
        "handlers": ["console"],
        "level": "INFO",
    },
}
