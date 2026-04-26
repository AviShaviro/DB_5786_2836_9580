import csv
import random
import os
from datetime import date, timedelta

# מציאת הנתיב המדויק של התיקייה שבה נמצא הסקריפט הזה
current_directory = os.path.dirname(os.path.abspath(__file__))

# שילוב נתיב התיקייה עם שם הקובץ שניצור
filename = os.path.join(current_directory, 'daily_puzzles.csv')
# הגדרת מספר הרשומות הנדרש
num_records = 20000

# תאריך התחלה ליצירת תאריכים ייחודיים
start_date = date(2020, 1, 1) 

with open(filename, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    
    # כתיבת שורת הכותרת (Headers)
    writer.writerow(['daily_puzzle_id', 'puzzle_id', 'puzzle_date', 'title', 'bonus_xp'])
    
    for i in range(1, num_records + 1):
        daily_puzzle_id = i
        
        # בחירת מזהה פאזל אקראי (בהנחה שיש פאזלים מ-1 עד 800 בטבלת PUZZLES)
        puzzle_id = random.randint(1, 800) 
        
        # הבטחת תאריך ייחודי לכל פאזל יומי על ידי הוספת יום לכל איטרציה
        puzzle_date = start_date + timedelta(days=i-1) 
        
        # יצירת כותרת דינאמית
        title = f"Daily Challenge {puzzle_date.strftime('%d/%m/%Y')}"
        
        # הגרלת נקודות הניסיון (לרוב נשאר 10, לפעמים ערך גבוה יותר)
        bonus_xp = random.choice([10, 10, 10, 15, 20, 30, 50]) 
        
        # כתיבת השורה לקובץ
        writer.writerow([daily_puzzle_id, puzzle_id, puzzle_date, title, bonus_xp])

print(f"קובץ {filename} נוצר בהצלחה עם {num_records} רשומות.")