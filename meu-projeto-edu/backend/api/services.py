from django.utils import timezone
from datetime import timedelta
from .models import Course
from .schemas import CourseIn

class CourseService:
    @staticmethod
    def list_courses():
        return Course.objects.all()

    @staticmethod
    def get_course(course_id: int) -> Course:
        return Course.objects.get(pk=course_id)

    @staticmethod
    def create_course(payload: CourseIn) -> Course:
        existing = Course.objects.filter(
            title=payload.title, 
            description=payload.description,
            active=payload.active
        ).first()
        
        if existing:
            return existing
            
        return Course.objects.create(**payload.dict())

    @staticmethod
    def process_review(course_id: int, quality: int) -> Course:
        """
        Simple Spaced Repetition Logic (SM-2 simplified)
        quality: 0 (forgot) to 5 (perfect)
        """
        course = Course.objects.get(pk=course_id)
        
        if quality >= 3:
            if course.interval == 0:
                course.interval = 1
            elif course.interval == 1:
                course.interval = 6
            else:
                course.interval = int(course.interval * course.ease_factor)
            
            # Update ease factor
            course.ease_factor = max(1.3, course.ease_factor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)))
        else:
            course.interval = 1
            course.ease_factor = max(1.3, course.ease_factor - 0.2)
            
        course.last_reviewed = timezone.now()
        course.next_review = course.last_reviewed + timedelta(days=course.interval)
        course.save()
        
        return course
