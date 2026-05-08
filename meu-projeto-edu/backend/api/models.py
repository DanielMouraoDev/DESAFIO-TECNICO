import datetime
from django.db import models
from django.utils import timezone

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
