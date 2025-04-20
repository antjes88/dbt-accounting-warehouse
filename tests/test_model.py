from src.model import ExampleValueObject, ExampleEntity
import datetime as dt

def test_example_value_object_equality():
    """
    GIVEN two ExampleValueObject instances with the same value and unit, and one with different value or unit
    WHEN comparing the objects for equality
    THEN objects with the same value and unit should be equal, objects with different value or unit should not be equal,
        and the object should not be equal to an instance of a different type
    """
    obj1 = ExampleValueObject(value=10.0, unit="kg")
    obj2 = ExampleValueObject(value=10.0, unit="kg")
    obj3 = ExampleValueObject(value=5.0, unit="lb")
    obj4 = ExampleValueObject(value=10.0, unit="g")
    obj5 = ExampleValueObject(value=5.0, unit="kg")

    assert obj1 == obj2  # Objects with the same value and unit should be equal
    assert obj1 != obj3  # Objects with different value or unit should not be equal
    assert obj1 != obj4  # Objects with different value or unit should not be equal
    assert obj1 != obj5  # Objects with different value or unit should not be equal
    assert obj1 != "not_a_value_object"  # Should not be equal to a different type


def test_example_entity_equality():
    """
    GIVEN three ExampleEntity instances, two with the same ID but different attributes, and one with a different ID
    WHEN comparing the entities for equality
    THEN entities with the same ID should be equal, entities with different IDs should not be equal,
        and the entity should not be equal to an instance of a different type
    """
    value_obj = ExampleValueObject(value=10.0, unit="kg")
    entity1 = ExampleEntity(id=1, name="Entity1", value_object=value_obj, created_at=dt.datetime(2023, 1, 1))
    entity2 = ExampleEntity(id=1, name="Entity2", value_object=value_obj, created_at=dt.datetime(2023, 1, 2))
    entity3 = ExampleEntity(id=2, name="Entity3", value_object=value_obj, created_at=dt.datetime(2023, 1, 3))

    assert entity1 == entity2  # Entities with the same ID should be equal
    assert entity1 != entity3  # Entities with different IDs should not be equal
    assert entity1 != "not_an_entity"  # Should not be equal to a different type