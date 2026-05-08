from django.utils import timezone
from datetime import timedelta
from .models import Course, Flashcard
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


class FlashcardService:
    @staticmethod
    def create_flashcard(*, user, front: str, back: str) -> Flashcard:
        return Flashcard.objects.create(user=user, front=front, back=back)

    @staticmethod
    def list_due_flashcards(*, user):
        return (
            Flashcard.objects.filter(user=user, next_review__lte=timezone.now())
            .order_by("next_review", "id")
        )

    @staticmethod
    def review_flashcard(*, user, flashcard_id: int, grade: int) -> Flashcard:
        """
        SM-2 simplified.
        grade: 1..5 (1=hard/forgot, 5=easy/perfect)

        Requirements hint:
        - if easy -> next review in 4 days (early steps)
        - if ok -> next review in 1 day (early steps)
        """
        if grade < 1 or grade > 5:
            raise ValueError("grade must be between 1 and 5")

        card = Flashcard.objects.get(pk=flashcard_id, user=user)
        now = timezone.now()

        if grade < 3:
            # Relearn quickly
            card.interval = 1
            card.easiness = max(1.3, card.easiness - 0.2)
        else:
            if card.interval <= 0:
                card.interval = 1
            elif card.interval == 1:
                # "Easy" tends to push further; keep it simple (1 or 4)
                card.interval = 4 if grade >= 4 else 1
            else:
                card.interval = max(1, int(round(card.interval * card.easiness)))

            # Update easiness factor (classic SM-2 formula)
            card.easiness = max(
                1.3,
                card.easiness
                + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02)),
            )

        card.next_review = now + timedelta(days=card.interval)
        card.save(update_fields=["interval", "easiness", "next_review", "updated_at"])
        return card
