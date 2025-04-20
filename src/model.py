from dataclasses import dataclass, field
import datetime as dt


@dataclass(frozen=True)
class ExampleValueObject:
    """
    Value object for example purposes.

    Attributes:
        value (float): Some numerical value.
        unit (str): Unit of the value.
    """

    value: float
    unit: str

    def __eq__(self, other) -> bool:
        if not isinstance(other, ExampleValueObject):
            return False
        return self.value == other.value and self.unit == other.unit


@dataclass
class ExampleEntity:
    """
    Entity class for example purposes.

    Attributes:
        id (int): Unique identifier.
        name (str): Name of the entity.
        value_object (ExampleValueObject): Associated value object.
        created_at (datetime): Timestamp of the entity creation.
    """

    id: int
    name: str
    value_object: ExampleValueObject
    created_at: dt.datetime = field(default_factory=dt.datetime.now)

    def __eq__(self, other) -> bool:
        if not isinstance(other, ExampleEntity):
            return False
        return self.id == other.id
            