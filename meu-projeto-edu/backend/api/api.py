from typing import List

from ninja import NinjaAPI
from ninja_jwt.authentication import JWTAuth
from ninja_jwt.tokens import RefreshToken

from .schemas import CourseIn, CourseOut, LoginIn, RegisterIn, TokenOut, RegisterOut, ReviewIn, ErrorOut
from .services import CourseService

api = NinjaAPI()

# JWT Authentication endpoints
@api.post("/login", response={200: TokenOut, 401: ErrorOut})
def obtain_token(request, payload: LoginIn):
    from django.contrib.auth import authenticate
    user = authenticate(username=payload.username, password=payload.password)
    if user is None:
        return 401, {"error": "Invalid credentials"}
    
    refresh = RefreshToken.for_user(user)
    return {
        "refresh": str(refresh),
        "access": str(refresh.access_token),
        "user": {"id": user.id, "username": user.username, "email": user.email}
    }

@api.post("/refresh", response={200: dict, 401: ErrorOut})
def refresh_token(request, refresh: str):
    from ninja_jwt.tokens import RefreshToken
    try:
        token = RefreshToken(refresh)
        return {
            "access": str(token.access_token),
        }
    except Exception:
        return 401, {"error": "Invalid refresh token"}

# Custom register endpoint
@api.post("/register", response={201: RegisterOut, 409: ErrorOut})
def register(request, payload: RegisterIn):
    from django.contrib.auth.models import User
    if User.objects.filter(username=payload.username).exists():
        return 409, {"error": "Username already exists"}
    if User.objects.filter(email=payload.email).exists():
        return 409, {"error": "Email already exists"}
    
    user = User.objects.create_user(username=payload.username, email=payload.email, password=payload.password)
    refresh = RefreshToken.for_user(user)
    return 201, {
        "user": {"id": user.id, "username": user.username, "email": user.email},
        "tokens": {
            "refresh": str(refresh),
            "access": str(refresh.access_token),
        }
    }

# Protected endpoints
@api.get("/courses", response=List[CourseOut], auth=JWTAuth())
def list_courses(request):
    return CourseService.list_courses()


@api.get("/courses/{course_id}", response=CourseOut, auth=JWTAuth())
def get_course(request, course_id: int):
    return CourseService.get_course(course_id)


@api.post("/courses", response=CourseOut, auth=JWTAuth())
def create_course(request, payload: CourseIn):
    return CourseService.create_course(payload)


@api.post("/courses/{course_id}/review", response=CourseOut, auth=JWTAuth())
def review_course(request, course_id: int, payload: ReviewIn):
    return CourseService.process_review(course_id, payload.quality)
