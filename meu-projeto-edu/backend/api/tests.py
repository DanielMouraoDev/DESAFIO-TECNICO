from django.test import TestCase
from .models import Course

class CourseModelTest(TestCase):
    def test_course_creation(self):
        course = Course.objects.create(
            title='Test Course',
            description='A test course description',
            active=True
        )
        self.assertEqual(course.title, 'Test Course')
        self.assertEqual(course.description, 'A test course description')
        self.assertTrue(course.active)
        self.assertEqual(str(course), 'Test Course')
