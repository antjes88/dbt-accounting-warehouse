from src.utils.logs import default_module_logger
import logging


def test_default_module_logger_writes_messages_to_console(caplog):
    """
    GIVEN a source file name
    WHEN default_module_logger is called and a log message is emitted
    THEN it should write the log message to the console
    """
    logger = default_module_logger(__file__)

    log_message = "This is a test log message"
    with caplog.at_level(logging.INFO):
        logger.info(log_message)

    assert log_message in caplog.text
