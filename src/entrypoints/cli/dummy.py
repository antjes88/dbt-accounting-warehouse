import click
from src.utils.logs import default_module_logger


logger = default_module_logger(__file__)


@click.command()
def dummy() -> None:

    logger.info(f"This is a dummy function.")
