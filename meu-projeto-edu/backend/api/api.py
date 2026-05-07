from typing import List

from ninja import NinjaAPI

from .schemas import CourseIn, CourseOut
from .services import CourseService

api = NinjaAPI()


@api.get("/courses", response=List[CourseOut])
def list_courses(request):
    return CourseService.list_courses()


@api.get("/courses/{course_id}", response=CourseOut)
def get_course(request, course_id: int):
    return CourseService.get_course(course_id)


@api.post("/courses", response=CourseOut)
def create_course(request, payload: CourseIn):
    return CourseService.create_course(payload)
