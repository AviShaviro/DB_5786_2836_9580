import csv
import random
from datetime import datetime, timedelta
import shared_logic

filename = shared_logic.get_csv_path('puzzle_attempt.csv')

# הגדרות הרשומות
num_records = 20000

# תאריך ושעת התחלה בסיסיים שמהם נוסיף זמן אקראי
start_datetime = datetime(2023, 1, 1, 8, 0, 0)

# יצירת הקובץ
with open(filename, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    
    # כתיבת שורת הכותרת (Headers)
    writer.writerow(['attempt_id', 'user_id', 'puzzle_id', 'is_successful', 'time_taken_sec', 'attempt_date'])
    
    for i in range(1, num_records + 1):
        attempt_id = i
        
        user_id = random.randint(1, shared_logic.MAX_USERS)
        
        # בחירת מזהה פאזל אקראי
        puzzle_id = random.randint(1, shared_logic.MAX_PUZZLES)
        
        # הגרלה האם הניסיון הצליח (True) או נכשל (False) - 65% סיכוי להצלחה
        is_successful = random.choices([True, False], weights=[65, 35])[0] 
        
        # כמה שניות לקח לפתור? (בין 15 שניות ל-900 שניות = 15 דקות)
        time_taken_sec = random.randint(15, 900) 
        
        # יצירת חותמת זמן (TIMESTAMP) אקראית במהלך שנה (365 ימים)
        random_seconds = random.randint(0, 365 * 24 * 60 * 60)
        attempt_date = start_datetime + timedelta(seconds=random_seconds)
        
        # כתיבת השורה לקובץ בפורמט התואם ל-SQL TIMESTAMP
        writer.writerow([
            attempt_id, 
            user_id, 
            puzzle_id, 
            is_successful, 
            time_taken_sec, 
            attempt_date.strftime('%Y-%m-%d %H:%M:%S')
        ])

print(f"הקובץ נוצר בהצלחה עם {num_records} רשומות.")
print(f"הקובץ נשמר בנתיב המלא: {filename}")