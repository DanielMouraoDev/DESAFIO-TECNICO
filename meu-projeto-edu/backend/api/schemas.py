from ninja import Schema

class CourseIn(Schema):
    title: str
    description: str
    active: bool = True

class CourseOut(Schema):
    id: int
    title: str
    description: str
    active: bool
