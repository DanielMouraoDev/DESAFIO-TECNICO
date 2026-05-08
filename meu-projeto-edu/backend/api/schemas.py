import datetime
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
    next_review: datetime.datetime
    interval: int

class ReviewIn(Schema):
    quality: int  # 0 to 5

class LoginIn(Schema):
    username: str
    password: str

class RegisterIn(Schema):
    username: str
    email: str
    password: str

class ErrorOut(Schema):
    error: str

class TokenOut(Schema):
    refresh: str
    access: str
    user: dict

class RegisterOut(Schema):
    user: dict
    tokens: dict


class FlashcardIn(Schema):
    front: str
    back: str


class FlashcardOut(Schema):
    id: int
    front: str
    back: str
    interval: int
    easiness: float
    next_review: datetime.datetime


class FlashcardReviewIn(Schema):
    grade: int  # 1 to 5
