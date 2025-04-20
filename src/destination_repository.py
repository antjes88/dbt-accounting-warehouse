from abc import ABC, abstractmethod
from src import model
from typing import List
from src import model


class AbstractDestinationRepository(ABC):
    """
    An abstract base class for destination repository interfaces that define methods to interact with a
    destination data storage in relation to Example Value Objects and Example Entities.

    Methods:
        load_example_value_objects(example_value_objects: List[model.ExampleValueObject]):
            interface to load Example Value Objects into the destination repository.
        load_example_entities(example_entities: List[model.ExampleEntity]):
            interface to load Example Entities into the destination repository.
    """

    @abstractmethod
    def load_example_value_objects(self, example_value_objects: List[model.ExampleValueObject]):
        """
        Abstract method to define the interface to load Example Value Objects into the
        destination repository.

        Args:
            example_value_objects (List[model.ExampleValueObject]):
                List of ExampleValueObject instances to be loaded into the repository.
        """
        raise NotImplementedError

    @abstractmethod
    def load_example_entities(self, example_entities: List[model.ExampleEntity]):
        """
        Abstract method to define the interface to load Example Entities into the
        destination repository.

        Args:
            example_entities (List[model.ExampleEntity]):
                List of Example Entity instances to be loaded into the repository.
        """
        raise NotImplementedError

