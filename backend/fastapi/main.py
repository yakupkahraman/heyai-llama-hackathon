from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from models import GameRequest, GameResponse, SpellingGameResponse, WordListResponse, ParagraphResponse, AnalysisRequest, AnalysisResponse, RoadmapResponse
from llama_service import LlamaService

app = FastAPI(
    title="Disleksik Bireyler İçin Oyun API",
    description="Fonolojik disleksi için kişiselleştirilmiş Hece Avcısı oyunu",
    version="1.0.0"
)

# CORS ayarları
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Llama servisini başlat
llama_service = LlamaService()

@app.get("/")
async def root():
    return {
        "message": "Disleksik Bireyler İçin Oyun API", 
        "version": "1.0.0",
        "available_games": ["phonological_game", "spelling_game", "word_list", "paragraph", "analysis", "roadmap"]
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": "2025-10-25"}

@app.post("/api/phonological-game", response_model=GameResponse)
async def create_phonological_game(request: GameRequest):
    """
    Kullanıcı bilgilerine göre Fonolojik (Hece Avcısı) oyunu oluşturur
    
    - **user_info**: Kullanıcının kayıt sırasında toplanan detaylı bilgileri
    - **return**: 5 sorudan oluşan oyun
    """
    try:
        # Llama'dan oyun sorularını al
        questions = await llama_service.generate_phonological_game(request.user_info)
        
        print(f"Alınan soru sayısı: {len(questions) if questions else 0}")
        
        if not questions:
            raise HTTPException(
                status_code=500, 
                detail="Oyun soruları oluşturulamadı"
            )
        
        if len(questions) != 5:
            print(f"⚠️ Beklenen 5 soru, alınan {len(questions)} soru")
            # 5 soru yoksa hata verme, mevcut soruları döndür
        
        return GameResponse(questions=questions)
        
    except Exception as e:
        error_message = str(e) if str(e) else "Bilinmeyen hata"
        print(f"Oyun oluşturma hatası: {error_message}")
        print(f"Hata tipi: {type(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=500, 
            detail=f"Oyun oluşturulamadı: {error_message}"
        )

@app.post("/api/spelling-game", response_model=SpellingGameResponse)
async def create_spelling_game(request: GameRequest):
    """
    Kullanıcı bilgilerine göre Yazım Hatası Tespit oyunu oluşturur
    
    - **user_info**: Kullanıcının kayıt sırasında toplanan detaylı bilgileri
    - **return**: 5 sorudan oluşan yazım hatası tespit oyunu
    """
    try:
        # Llama'dan oyun sorularını al
        questions = await llama_service.generate_spelling_game(request.user_info)
        
        print(f"Alınan spelling soru sayısı: {len(questions) if questions else 0}")
        
        if not questions:
            raise HTTPException(
                status_code=500, 
                detail="Yazım hatası tespit oyunu soruları oluşturulamadı"
            )
        
        if len(questions) != 5:
            print(f"⚠️ Beklenen 5 soru, alınan {len(questions)} soru")
        
        return SpellingGameResponse(questions=questions)
        
    except Exception as e:
        error_message = str(e) if str(e) else "Bilinmeyen hata"
        print(f"Spelling oyun oluşturma hatası: {error_message}")
        print(f"Hata tipi: {type(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=500, 
            detail=f"Yazım hatası tespit oyunu oluşturulamadı: {error_message}"
        )

@app.post("/api/word-list", response_model=WordListResponse)
async def create_word_list(request: GameRequest):
    """
    Kullanıcının ilgi alanına göre 5 rastgele Türkçe kelime döndürür
    
    - **user_info**: Kullanıcının kayıt sırasında toplanan detaylı bilgileri
    - **return**: İlgi alanına uygun 5 rastgele Türkçe kelime
    """
    try:
        # Llama'dan kelime listesini al
        words = await llama_service.generate_word_list(request.user_info)
        
        print(f"Generated word list: {words}")
        
        if not words or len(words) == 0:
            raise HTTPException(
                status_code=500, 
                detail="Kelime listesi oluşturulamadı"
            )
        
        return WordListResponse(words=words)
        
    except Exception as e:
        error_message = str(e) if str(e) else "Bilinmeyen hata"
        print(f"Kelime listesi oluşturma hatası: {error_message}")
        print(f"Hata tipi: {type(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=500, 
            detail=f"Kelime listesi oluşturulamadı: {error_message}"
        )

@app.post("/api/paragraph", response_model=ParagraphResponse)
async def create_paragraph(request: GameRequest):
    """
    Kullanıcının ilgi alanına göre 5 adet 4 cümlelik anlamlı paragraf oluşturur
    
    - **user_info**: Kullanıcının kayıt sırasında toplanan detaylı bilgileri
    - **return**: İlgi alanına uygun 5 adet 4 cümlelik paragraf
    """
    try:
        # Llama'dan paragrafları al
        paragraphs = await llama_service.generate_paragraph(request.user_info)
        
        print(f"Generated paragraphs: {paragraphs}")
        
        if not paragraphs or len(paragraphs) == 0:
            raise HTTPException(
                status_code=500, 
                detail="Paragraflar oluşturulamadı"
            )
        
        return ParagraphResponse(paragraphs=paragraphs)
        
    except Exception as e:
        error_message = str(e) if str(e) else "Bilinmeyen hata"
        print(f"Paragraf oluşturma hatası: {error_message}")
        print(f"Hata tipi: {type(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=500, 
            detail=f"Paragraflar oluşturulamadı: {error_message}"
        )

@app.post("/api/analysis", response_model=AnalysisResponse)
async def create_analysis(request: AnalysisRequest):
    """
    Kullanıcı bilgileri ve istatistiklerini analiz ederek kişiselleştirilmiş rapor oluşturur
    
    - **user_info**: Kullanıcının kayıt sırasında toplanan detaylı bilgileri
    - **user_statistics**: Kullanıcının oyun performans istatistikleri
    - **return**: Kişiselleştirilmiş analiz raporu
    """
    try:
        # Llama'dan analizi al
        analysis = await llama_service.generate_analysis(request.user_info, request.user_statistics)
        
        print(f"Generated analysis: {analysis}")
        
        if not analysis or not analysis.strip():
            raise HTTPException(
                status_code=500, 
                detail="Analiz raporu oluşturulamadı"
            )
        
        return AnalysisResponse(analysis=analysis)
        
    except Exception as e:
        error_message = str(e) if str(e) else "Bilinmeyen hata"
        print(f"Analiz oluşturma hatası: {error_message}")
        print(f"Hata tipi: {type(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=500, 
            detail=f"Analiz raporu oluşturulamadı: {error_message}"
        )

@app.post("/api/roadmap", response_model=RoadmapResponse)
async def create_roadmap(request: GameRequest):
    """
    Kullanıcı bilgilerine göre kişiselleştirilmiş 7 günlük yol haritası oluşturur
    
    - **user_info**: Kullanıcının kayıt sırasında toplanan detaylı bilgileri
    - **return**: 7 günlük egzersiz planı
    """
    try:
        # Llama'dan yol haritasını al
        roadmap_data = await llama_service.generate_roadmap(request.user_info)
        
        print(f"Generated roadmap: {roadmap_data}")
        
        if not roadmap_data or not roadmap_data.get("daily_plans"):
            raise HTTPException(
                status_code=500, 
                detail="Yol haritası oluşturulamadı"
            )
        
        return RoadmapResponse(**roadmap_data)
        
    except Exception as e:
        error_message = str(e) if str(e) else "Bilinmeyen hata"
        print(f"Yol haritası oluşturma hatası: {error_message}")
        print(f"Hata tipi: {type(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=500, 
            detail=f"Yol haritası oluşturulamadı: {error_message}"
        )

@app.get("/api/sample-user")
async def get_sample_user():
    """
    Test için örnek kullanıcı bilgileri döndürür
    """
    return {
        "user_info": {
            "age_group": "14-17",
            "hard_area": "Hece tanıma ve ses-harf eşleştirme zorluğu",
            "reading_goal": "Takılmadan kelime okuma ve hece ayırma becerisi kazanma",
            "diagnosis_time": "6 ay önce fonolojik disleksi tanısı aldı",
            "motivating_games": "Kelime oyunları, ses eşleştirme, hızlı tanıma oyunları",
            "working_with_professional": "Özel eğitim uzmanı ile haftada 2 saat çalışıyor"
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
