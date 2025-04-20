from abc import ABC, abstractmethod
from typing import List

from src import model


class AbstractSourceRepository(ABC):
    """
    An abstract base class for source repository interfaces that define methods to interact with a
    source data storage from where to extract Example Value Objects and Example Entities.

    Methods:
        get_example_value_objects() -> List[model.ExampleValueObject]:
            Retrieves Example Value Objects from the source repository.
        get_example_entities() -> List[model.ExampleEntity]:
            Retrieves Example Entities from the source repository.
    """

    @abstractmethod
    def get_example_value_objects(self) -> List[model.ExampleValueObject]:
        """
        Retrieves Example Value Objects from the source repository.

        Returns:
            list[model.ExampleValueObject]: A list of ExampleValueObject instances.
        """
        raise NotImplementedError

    @abstractmethod
    def get_example_entities(self) -> List[model.ExampleEntity]:
        """
        Retrieves Example Entities from the source repository.

        Returns:
            list[model.ExampleEntity]: A list of ExampleEntity instances.
        """
        raise NotImplementedError
