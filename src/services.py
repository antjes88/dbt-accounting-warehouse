from src import source_repository, destination_repository, model


def sync_example_value_objects(
    source_repository: source_repository.AbstractSourceRepository,
    destination_repository: destination_repository.AbstractDestinationRepository,
):
    """
    Syncs destination repository with source repository.

    Args:
        source_repository (source_repository.AbstractSourceRepository):
            The data repository to get Example Value Objects from.
        destination_repository (destination_repository.AbstractDestinationRepository):
            The data repository to load Example Value Objects into.
        
    """
    example_value_objects = source_repository.get_example_value_objects()
    destination_repository.load_example_value_objects(example_value_objects)


def sync_example_entities(
    source_repository: source_repository.AbstractSourceRepository,
    destination_repository: destination_repository.AbstractDestinationRepository,
):
    """
    Syncs destination repository with source repository.

    Args:
        source_repository (source_repository.AbstractSourceRepository):
            The data repository to get Example Entities from.
        destination_repository (destination_repository.AbstractDestinationRepository):
            The data repository to load Example Entities into.
        
    """
    example_entities = source_repository.get_example_entities
    destination_repository.load_example_entities(example_entities)
