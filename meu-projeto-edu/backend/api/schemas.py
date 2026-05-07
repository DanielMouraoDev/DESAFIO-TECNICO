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

class LoginIn(Schema):
    username: str
    password: str

class RegisterIn(Schema):
    username: str
    email: str
    password: str

class TokenOut(Schema):
    refresh: str
    access: str
    user: dict

class RegisterOut(Schema):
    user: dict
    tokens: dict
