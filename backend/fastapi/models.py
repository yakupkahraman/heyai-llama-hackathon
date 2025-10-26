from pydantic import BaseModel
from typing import List, Optional

class UserInfo(BaseModel):
    age_group: str  # "14-17" veya "17-24"
    hard_area: str  # Zorluk alanı
    reading_goal: str  # Hedef (örn. takılmadan okuma yapma)
    diagnosis_time: str  # Tanı durumu
    motivating_games: str  # Tercih edilen oyun tipleri
    working_with_professional: str  # Uzmanla çalışma durumu

class Question(BaseModel):
    question: str  # Soru açıklaması
    options: List[str]  # Soru seçenekleri (4 adet)
    correct_answers: List[int]  # Doğru cevapların indisleri

class GameResponse(BaseModel):
    questions: List[Question]

class GameRequest(BaseModel):
    user_info: UserInfo

class SpellingQuestion(BaseModel):
    words: List[str]  # 5 kelime (4 doğru, 1 hatalı)
    wrong_index: int  # Hatalı kelimenin indisi (0-4)

class SpellingGameResponse(BaseModel):
    questions: List[SpellingQuestion]  # 5 adet spelling sorusu

class WordListResponse(BaseModel):
    words: List[str]  # 5 rastgele Türkçe kelime

class ParagraphResponse(BaseModel):
    paragraphs: List[str]  # 5 adet 4 cümlelik anlamlı paragraf

class UserStatistics(BaseModel):
    total_games_played: int  # Toplam oynanan oyun sayısı
    phonological_success_rate: str  # Fonolojik oyun başarı oranı (örn: "72.5")
    spelling_success_rate: str  # Yazım oyunu başarı oranı (örn: "68.0")
    word_list_success_rate: str  # Kelime listesi oyunu başarı oranı (örn: "85.2")
    paragraph_success_rate: str  # Paragraf oyunu başarı oranı (örn: "79.8")

class AnalysisRequest(BaseModel):
    user_info: UserInfo
    user_statistics: UserStatistics

class AnalysisResponse(BaseModel):
    analysis: str  # Kişiselleştirilmiş analiz paragrafı

class DailyPlan(BaseModel):
    day: int  # Gün numarası (1-7 veya 1-30)
    phonological_games: int  # Fonolojik oyun sayısı
    spelling_games: int  # Yazım oyunu sayısı
    word_exercises: int  # Kelime egzersizi sayısı
    reading_time: int  # Okuma süresi (dakika)

class RoadmapResponse(BaseModel):
    daily_plans: List[DailyPlan]  # Günlük plan listesi
    total_duration_days: int  # Toplam süre (gün)
    focus_areas: List[str]  # Odaklanılacak alanlar
