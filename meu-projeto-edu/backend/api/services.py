from .models import Course
from .schemas import CourseIn


class CourseService:
    @staticmethod
    def list_courses():
        return list(Course.objects.all())

    @staticmethod
    def get_course(course_id: int) -> Course:
        return Course.objects.get(pk=course_id)

    @staticmethod
    def create_course(payload: CourseIn) -> Course:
        return Course.objects.create(**payload.dict())
