# import requests
# import json

# url = "https://backend.metacritic.com/v1/xapi/finder/metacritic/web"
# params = {
#     "sortBy": "-metaScore",
#     "productType": "games",
#     "releaseYearMin": 1958,
#     "releaseYearMax": 2024,
#     "limit": 24  
# }

# headers = {
#     "accept": "application/json, text/plain, */*",
#     "accept-language": "tr-TR,tr;q=0.7",
#     "priority": "u=1, i",
#     "sec-ch-ua": "\"Chromium\";v=\"130\", \"Brave\";v=\"130\", \"Not?A_Brand\";v=\"99\"",
#     "sec-ch-ua-mobile": "?0",
#     "sec-ch-ua-platform": "\"Windows\"",
#     "sec-fetch-dest": "empty",
#     "sec-fetch-mode": "cors",
#     "sec-fetch-site": "same-site",
#     "sec-gpc": "1"
# }

# all_games = []
# total_results = 0
# offset = 0

# while True:
#     params["offset"] = offset
#     response = requests.get(url, headers=headers, params=params)
    
#     if response.status_code == 200:
#         data = response.json()
#         total_results = data["data"]["totalResults"]
#         items = data["data"]["items"]
#         all_games.extend(items)
        
#         offset += len(items)  
#         if offset >= total_results:
#             break  
#     else:
#         print(f"Hata: {response.status_code} - {response.text}")
#         break


# with open("games.json", "w", encoding="utf-8") as f:
#     json.dump({"data": all_games}, f, ensure_ascii=False, indent=4)




# Read json and create a database
# 
import json
import pandas as pd

with open('games.json', 'r', encoding='utf-8') as f:
    data = json.load(f)


games = data['data']


rows = []

for game in games:
    
    game_id = game['id']
    title = game['title']
    premiere_year = game['premiereYear']
    release_date = game['releaseDate']
    rating = game['rating']
    description = game['description']
    critic_score = game['criticScoreSummary']['score'] if 'criticScoreSummary' in game else None
    
    
    genres = ", ".join(genre['name'] for genre in game.get('genres', []))

    rows.append({
        'id': game_id,
        'title': title,
        'premiere_year': premiere_year,
        'release_date': release_date,
        'rating': rating,
        'description': description,
        'genres': genres,
        'critic_score': critic_score
    })

df = pd.DataFrame(rows)

df.to_csv('games.csv', index=False, encoding='utf-8')


