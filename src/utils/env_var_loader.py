import os
from dotenv import load_dotenv
from typing import Optional


def env_var_loader(file_name: str, file_path: Optional[str] = None):
    """
    Load environment variables from a specified file using python-dotenv.

    Args:
        file_name (str): The name of the environment file.
        file_path (str, optional): The path to the directory containing the environment file.
    """
    if file_path:
        env_path = os.path.join(file_path, file_name)
    else:
        wd = os.getcwd()
        env_path = os.path.join(wd, file_name)

    if os.path.isfile(env_path):
        load_dotenv(dotenv_path=env_path, override=True)
