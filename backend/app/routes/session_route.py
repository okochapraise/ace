from fastapi import APIRouter, Depends
from app.dependencies.auth_dependency import get_current_user

router = APIRouter()

@router.get("/protected")
def protected_route(user=Depends(get_current_user)):
    return {"message": "You are authenticated!", "user": user}