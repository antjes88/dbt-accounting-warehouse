from logging import INFO, Logger, StreamHandler, getLogger


def default_module_logger(src_file_name: str) -> Logger:
    """
    Gets or creates a module logger.

    Args:
        src_file_name (str): The name of the source file/module using the logger.
    Returns:
        Logger: default module logger.
    """
    logger = getLogger(src_file_name)
    if len(logger.handlers) == 0:
        handler = StreamHandler()
        logger.addHandler(handler)
    logger.setLevel(INFO)

    return logger
