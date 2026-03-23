from django.utils import timezone
from hostel.models import CaretakerDuty


def resolve_authority(user):
    """
    Returns:
    {
        "role": "STUDENT" | "BLOCK_WARDEN" | "CHIEF_WARDEN",
        "is_caretaker": True/False,
        "block": Block or None
    }
    """

    today = timezone.localdate()

    # Chief Warden
    if user.role == "CHIEF_WARDEN":
        return {
            "role": "CHIEF_WARDEN",
            "is_caretaker": False,
            "block": None
        }

    # Block Warden
    if user.role == "BLOCK_WARDEN":
        return {
            "role": "BLOCK_WARDEN",
            "is_caretaker": False,
            "block": user.block
        }

    # Check Caretaker Assignment
    caretaker = CaretakerDuty.objects.filter(
        caretaker=user,
        duty_date=today
    ).first()

    if caretaker:
        return {
            "role": "CARETAKER",
            "is_caretaker": True,
            "block": caretaker.block
        }

    # Default (Student or no authority)
    return {
        "role": user.role,
        "is_caretaker": False,
        "block": user.block
    }
