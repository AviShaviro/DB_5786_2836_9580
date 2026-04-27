import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MAX_USERS = 600
MAX_PUZZLES = 20000

def get_csv_path(filename):
    """מחזיר נתיב מלא לקובץ בתוך תיקיית הפרויקט"""
    return os.path.join(BASE_DIR, filename)