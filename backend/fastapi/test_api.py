#!/usr/bin/env python3.9
"""
Disleksik Bireyler İçin Hece Avcısı Oyunu API - Test Scripti
"""
import requests
import json
from typing import Dict, Any

API_BASE_URL = "http://localhost:8000"

def test_api_health():
    """API sağlık durumunu test eder"""
    print("🔍 API sağlık durumu kontrol ediliyor...")
    try:
        response = requests.get(f"{API_BASE_URL}/health")
        if response.status_code == 200:
            print("✅ API sağlıklı!")
            print(f"   Yanıt: {response.json()}")
        else:
            print(f"❌ API sağlık kontrolü başarısız: {response.status_code}")
    except Exception as e:
        print(f"❌ API'ye bağlanılamadı: {e}")

def test_sample_user():
    """Örnek kullanıcı endpoint'ini test eder"""
    print("\n🔍 Örnek kullanıcı bilgileri alınıyor...")
    try:
        response = requests.get(f"{API_BASE_URL}/api/sample-user")
        if response.status_code == 200:
            print("✅ Örnek kullanıcı bilgileri alındı!")
            sample_data = response.json()
            print(f"   Yaş Grubu: {sample_data['user_info']['age_group']}")
            print(f"   Zorluk Alanı: {sample_data['user_info']['hard_area']}")
            return sample_data
        else:
            print(f"❌ Örnek kullanıcı alınamadı: {response.status_code}")
    except Exception as e:
        print(f"❌ Hata: {e}")
    return None

def test_phonological_game(user_data: Dict[str, Any]):
    """Fonolojik oyun endpoint'ini test eder"""
    print("\n🔍 Fonolojik oyun oluşturuluyor...")
    try:
        response = requests.post(
            f"{API_BASE_URL}/api/phonological-game",
            json=user_data,
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code == 200:
            print("✅ Fonolojik oyun başarıyla oluşturuldu!")
            game_data = response.json()
            questions = game_data.get("questions", [])
            
            print(f"   📊 Toplam soru sayısı: {len(questions)}")
            
            for i, question in enumerate(questions, 1):
                print(f"\n   🎯 Soru {i}: {question['question']}")
                print(f"      Seçenekler: {', '.join(question['options'])}")
                print(f"      Doğru cevaplar: {[question['options'][idx] for idx in question['correct_answers']]}")
            
            return game_data
        else:
            print(f"❌ Oyun oluşturulamadı: {response.status_code}")
            print(f"   Hata: {response.text}")
    except Exception as e:
        print(f"❌ Hata: {e}")
    return None

def test_different_user_profiles():
    """Farklı kullanıcı profilleri ile test yapar"""
    print("\n🔍 Farklı kullanıcı profilleri ile test ediliyor...")
    
    test_profiles = [
        {
            "user_info": {
                "age_group": "17-24",
                "hard_area": "Kelime tanıma ve okuma hızı",
                "reading_goal": "Akademik metinleri anlayarak okuma",
                "diagnosis_time": "Üniversitede tespit edildi",
                "motivating_games": "Strateji oyunları, zeka oyunları",
                "working_with_professional": "Kendi kendine çalışıyor"
            }
        },
        {
            "user_info": {
                "age_group": "14-17",
                "hard_area": "Yazı yazma ve harf karıştırma",
                "reading_goal": "Ders kitaplarını rahat okuma",
                "diagnosis_time": "İlkokul döneminde tanı aldı",
                "motivating_games": "Görsel hafıza oyunları",
                "working_with_professional": "Ayda bir uzman kontrolü"
            }
        }
    ]
    
    for i, profile in enumerate(test_profiles, 1):
        print(f"\n   👤 Test Profili {i}:")
        print(f"      Yaş: {profile['user_info']['age_group']}")
        print(f"      Zorluk: {profile['user_info']['hard_area']}")
        
        game = test_phonological_game(profile)
        if game:
            print(f"      ✅ Bu profil için oyun başarıyla oluşturuldu!")
        else:
            print(f"      ❌ Bu profil için oyun oluşturulamadı!")

def main():
    """Ana test fonksiyonu"""
    print("🎮 Disleksik Bireyler İçin Hece Avcısı Oyunu API - Test Başlatılıyor")
    print("=" * 70)
    
    # API sağlık kontrolü
    test_api_health()
    
    # Örnek kullanıcı testi
    sample_user = test_sample_user()
    
    if sample_user:
        # Ana oyun testi
        test_phonological_game(sample_user)
        
        # Farklı profiller ile test
        test_different_user_profiles()
    
    print("\n" + "=" * 70)
    print("🏁 Test tamamlandı!")
    print("\n📋 API Dokümantasyonu:")
    print(f"   Swagger UI: {API_BASE_URL}/docs")
    print(f"   ReDoc: {API_BASE_URL}/redoc")

if __name__ == "__main__":
    main()
