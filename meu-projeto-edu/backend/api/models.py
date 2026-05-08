import datetime
from django.db import models
from django.utils import timezone
from django.conf import settings

class Course(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    active = models.BooleanField(default=True)
    
    # Spaced Repetition Fields
    last_reviewed = models.DateTimeField(null=True, blank=True)
    next_review = models.DateTimeField(default=timezone.now)
    interval = models.IntegerField(default=0)  # in days
    ease_factor = models.FloatField(default=2.5)

    def __str__(self):
        return self.title


class Flashcard(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="flashcards")
    front = models.TextField()
    back = models.TextField()

    interval = models.IntegerField(default=0)  # days
    easiness = models.FloatField(default=2.5)
    next_review = models.DateTimeField(default=timezone.now)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Flashcard({self.id}) for {self.user_id}"
