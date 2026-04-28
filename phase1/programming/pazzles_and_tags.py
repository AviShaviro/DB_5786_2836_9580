
'''#########################    NEED to DOWNLOAD   ##########################
for this script you NEED to DOWNLOAD the lichess puzzles data
from https://database.lichess.org/#puzzles
and place the 'lichess_db_puzzle.csv' file in the same folder as this script.
###########################################################################'''

import csv
from shared_logic import get_csv_path

# הגדרות
input_file = get_csv_path('lichess_db_puzzle.csv') # שם הקובץ של lichess
tags_output = get_csv_path('tags.csv')
puzzles_output = get_csv_path('puzzles.csv')
num_records = 30000

def process_chess_data():
    unique_themes = set()
    puzzles_data = []
    
    print(f"Reading {input_file}...")
    
    try:
        with open(input_file, mode='r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            
            for i, row in enumerate(reader):
                if i >= num_records:
                    break
                
                # חילוץ התגיות מעמודת Themes (מופרדות ברווחים)
                themes = row['Themes'].split()
                if themes:
                    # אנחנו לוקחים את התגית הראשונה כ"תגית ראשית" עבור ה-Foreign Key
                    primary_theme = themes[0]
                    unique_themes.add(primary_theme)
                    
                    # שמירת נתוני הפאזל זמנית
                    puzzles_data.append({
                        'fen': row['FEN'],
                        'moves': row['Moves'],
                        'elo': row['Rating'],
                        'theme_name': primary_theme
                    })
        
        # 1. יצירת מיפוי ותוצאות עבור TAGS
        # אנחנו יוצרים רשימה ממוינת כדי שה-ID יהיה עקבי
        sorted_themes = sorted(list(unique_themes))
        theme_to_id = {name: i + 1 for i, name in enumerate(sorted_themes)}
        
        print(f"Generating {tags_output} with {len(sorted_themes)} unique tags...")
        with open(tags_output, mode='w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(['tag_id', 'tag_name', 'description']) # כותרות ל-SQL
            for theme in sorted_themes:
                writer.writerow([theme_to_id[theme], theme, f"Chess tactic: {theme}"])
        
        # 2. יצירת קובץ ה-PUZZLES עם ה-ID המקושר
        print(f"Generating {puzzles_output}...")
        with open(puzzles_output, mode='w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(['fen_string', 'solution_moves', 'difficulty_elo', 'tag_id'])
            
            for p in puzzles_data:
                tag_id = theme_to_id[p['theme_name']]
                writer.writerow([p['fen'], p['moves'], p['elo'], tag_id])
                
        print("Done! Both files are ready for import.")

    except FileNotFoundError:
        print(f"Error: The file '{input_file}' was not found. Please make sure it's in the same folder.")

process_chess_data()