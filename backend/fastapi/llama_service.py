import httpx
import json
from typing import List
from models import UserInfo, Question, SpellingQuestion

class LlamaService:
    def __init__(self, llama_url: str = "http://172.30.48.23:11434"):
        self.llama_url = llama_url
        self.model_name = "llama3:8b"#'ahmets/ytu_cosmos'  # Mevcut model adı
    
    async def generate_phonological_game(self, user_info: UserInfo) -> List[Question]:
        """
        Kullanıcı bilgilerine göre Fonolojik (Hece Avcısı) oyunu soruları üretir
        """
        prompt = self._create_phonological_prompt(user_info)
        
        async with httpx.AsyncClient(timeout=60.0) as client:
            try:
                response = await client.post(
                    f"{self.llama_url}/api/generate",
                    json={
                        "model": self.model_name,
                        "prompt": prompt,
                        "format": "json",
                        "stream": False,
                        "options": {
                            "temperature": 0.8,  # Daha çeşitli sonuçlar için
                            "top_p": 0.9
                        }
                    }
                )
                response.raise_for_status()
                
                llama_response = response.json()
                generated_text = llama_response.get("response", "")
                
                # JSON yanıtını parse et
                questions_data = json.loads(generated_text)
                
                # Doğru cevapları kontrol et ve düzelt
                corrected_questions = []
                for q_data in questions_data.get("questions", []):
                    corrected_q = self._fix_correct_answers(q_data)
                    corrected_questions.append(Question(**corrected_q))
                
                return corrected_questions
                
            except httpx.RequestError as e:
                print(f"Llama RequestError: {e}")
                raise Exception(f"Llama API'sine bağlanılamıyor: {str(e)}")
            except httpx.HTTPStatusError as e:
                print(f"Llama HTTPStatusError: {e}")
                print(f"Response: {e.response.text if hasattr(e, 'response') else 'No response'}")
                raise Exception(f"Llama API HTTP hatası: {e.response.status_code}")
            except json.JSONDecodeError as e:
                print(f"JSON Decode Error: {e}")
                print(f"Generated text: {generated_text}")
                raise Exception(f"Llama'dan gelen yanıt JSON formatında değil: {str(e)}")
            except Exception as e:
                print(f"Genel Exception: {e}")
                print(f"Exception type: {type(e)}")
                import traceback
                traceback.print_exc()
                raise Exception(f"Beklenmeyen hata: {str(e)}")
    
    def _create_phonological_prompt(self, user_info: UserInfo) -> str:
        """
        Kullanıcı bilgilerine göre Llama için prompt oluşturur
        """
        prompt = f"""
Disleksik bireyler için "Hece Avcısı" oyunu oluştur. TAM OLARAK 5 SORU yap.

Yaş Grubu: {user_info.age_group}

KURALLAR:
- Her soruda 2 harfli hedef hece ver. (ka, al, er, on, an, el, at, it, vb.)
- 4 tane GERÇEK Türkçe kelime seçeneği sun.
- Hedef hece, kelimenin başında, ortasında veya sonunda olabilir
- Her soruda EN AZ 1, EN FAZLA 3 doğru cevap olmak zorunda. 
- Cevap seçenekleri arasında hedef heceyi içeren kelimeler doğru kabul edilir
- Cevap seçenekleri arasında hedef heceyi içeren EN AZ 1 kelime olmalı.
- Hedef hece seçeneklerin hepsinde birden kelimenin başında bulunamaz. Yani "ka" hecesi için "kalem", "kapı", "kasa", "kağıt",gibi kelimeler aynı soru içerisinde seçenek olarak kullanılamaz.
- Seçenkler TEK KELİME olmalı, birden fazla kelime içeren seçenekler kullanma.

ÖNEMLİ:
- Soru metni şu şekilde olmalı: "Hedef hece 'XX' içeren kelimeleri seç:"
- Soru metni SADECE TÜRKÇE OLMALI.
- Türkçe karakter farkına dikkat et: "ol" != "öl", "ul" != "ül"
- Her soruda farklı kelimeler kullan
- BİR SORUNUN CEVAPLARI 4 ADET OLAMAZ. 

JSON formatında 5 soru döndür:
{{
  "questions": [
    {{
      "question": "Hedef hece 'ka' içeren kelimeleri seç:",
      "options": ["word1", "word2", "word3", "word4"],
      "correct_answers": [0]
    }}
  ]
}}
"""
        return prompt
    
    def _fix_correct_answers(self, question_data: dict) -> dict:
        """
        Llama'dan gelen sorunun correct_answers değerlerini kontrol eder ve düzeltir
        """
        import re
        
        question = question_data.get("question", "")
        options = question_data.get("options", [])
        
        # Soruda hedef ses/heceyi bul
        target_match = re.search(r"'([^']+)'", question)
        if not target_match:
            # Hedef bulunamazsa mevcut correct_answers'ı koru
            return question_data
            
        target_sound = target_match.group(1).lower()
        
        # Her seçenekte hedef ses/hece var mı kontrol et
        correct_indices = []
        for i, option in enumerate(options):
            option_lower = option.lower()
            # Türkçe karakter duyarlı arama
            if target_sound in option_lower:
                correct_indices.append(i)
                print(f"✅ '{target_sound}' bulundu: {option} (indis: {i})")
            else:
                print(f"❌ '{target_sound}' bulunamadı: {option}")
        
        # En az 1, en fazla 3 doğru cevap kontrolü
        if len(correct_indices) == 0:
            print(f"⚠️ Hiç doğru cevap bulunamadı! İlk seçeneği doğru kabul ediyoruz.")
            correct_indices = [0]  # En az 1 doğru cevap garantisi
        elif len(correct_indices) > 3:
            print(f"⚠️ {len(correct_indices)} doğru cevap var, ilk 3'ünü alıyoruz.")
            correct_indices = correct_indices[:3]  # En fazla 3 doğru cevap
        
        print(f"Final correct_answers: {correct_indices}")
        
        # Düzeltilmiş question_data döndür
        corrected_data = question_data.copy()
        corrected_data["correct_answers"] = correct_indices
        
        return corrected_data

    async def generate_spelling_game(self, user_info: UserInfo) -> List[SpellingQuestion]:
        """
        Kullanıcı bilgilerine göre Yazım Hatası Tespit oyunu oluşturur
        """
        prompt = self._create_spelling_prompt(user_info)
        
        async with httpx.AsyncClient(timeout=120.0) as client:
            try:
                response = await client.post(
                    f"{self.llama_url}/api/generate",
                    json={
                        "model": self.model_name,
                        "prompt": prompt,
                        "format": "json",
                        "stream": False,
                        "options": {
                            "temperature": 0.8,  # Daha çeşitli sonuçlar için
                            "top_p": 0.9
                        }
                    }
                )
                response.raise_for_status()
                
                llama_response = response.json()
                generated_text = llama_response.get("response", "")
                
                # JSON yanıtını parse et
                spelling_data = json.loads(generated_text)
                
                # Her soruyu kontrol et ve düzelt
                corrected_questions = []
                for q_data in spelling_data.get("questions", []):
                    corrected_q = self._fix_spelling_game(q_data)
                    corrected_questions.append(SpellingQuestion(**corrected_q))
                
                return corrected_questions
                
            except httpx.RequestError as e:
                print(f"Llama RequestError: {e}")
                raise Exception(f"Llama API'sine bağlanılamıyor: {str(e)}")
            except httpx.HTTPStatusError as e:
                print(f"Llama HTTPStatusError: {e}")
                print(f"Response: {e.response.text if hasattr(e, 'response') else 'No response'}")
                raise Exception(f"Llama API HTTP hatası: {e.response.status_code}")
            except json.JSONDecodeError as e:
                print(f"JSON Decode Error: {e}")
                print(f"Generated text: {generated_text}")
                raise Exception(f"Llama'dan gelen yanıt JSON formatında değil: {str(e)}")
            except Exception as e:
                print(f"Genel Exception: {e}")
                print(f"Exception type: {type(e)}")
                import traceback
                traceback.print_exc()
                raise Exception(f"Beklenmeyen hata: {str(e)}")

    def _create_spelling_prompt(self, user_info: UserInfo) -> str:
        """
        Yazım hatası tespit oyunu için prompt oluşturur
        """
        # 50 adet doğru ve yanlış kelime çifti
        word_pairs = [
            {"correct": "bilgisayar", "wrong": "pilgisayar"},  # b->p
            {"correct": "matematik", "wrong": "natematik"},    # m->n
            {"correct": "teknoloji", "wrong": "teknoloci"},    # j->c (görsel benzerlik)
            {"correct": "doktor", "wrong": "toktor"},          # d->t
            {"correct": "kahraman", "wrong": "gahraman"},      # k->g
            {"correct": "merhaba", "wrong": "nerhaba"},        # m->n
            {"correct": "algoritma", "wrong": "algoritna"},    # m->n
            {"correct": "elektronik", "wrong": "eleftronik"},  # k->f (görsel)
            {"correct": "psikoloji", "wrong": "bsikoloji"},    # p->b
            {"correct": "biyoloji", "wrong": "piyoloji"},      # b->p
            {"correct": "kimya", "wrong": "ginya"},            # k->g, m->n
            {"correct": "fizik", "wrong": "fisik"},            # z->s
            {"correct": "tarih", "wrong": "tarıh"},            # i->ı
            {"correct": "coğrafya", "wrong": "çoğrafya"},      # c->ç
            {"correct": "edebiyat", "wrong": "edepiyat"},      # b->p
            {"correct": "felsefe", "wrong": "felşefe"},        # s->ş
            {"correct": "sosyoloji", "wrong": "şosyoloji"},    # s->ş
            {"correct": "antropoloji", "wrong": "antropoloci"}, # j->c
            {"correct": "arkeoloji", "wrong": "argeoloji"},    # k->g
            {"correct": "mühendislik", "wrong": "nühendislik"}, # m->n
            {"correct": "mimarlık", "wrong": "minarlık"},      # m->n
            {"correct": "hukuk", "wrong": "huguk"},            # k->g
            {"correct": "ekonomi", "wrong": "egonomi"},        # k->g
            {"correct": "işletme", "wrong": "işretme"},        # l->r
            {"correct": "muhasebe", "wrong": "muhaşebe"},      # s->ş
            {"correct": "pazarlama", "wrong": "pasarlama"},    # z->s
            {"correct": "finans", "wrong": "finañs"},          # s->ş (son harf)
            {"correct": "yönetim", "wrong": "yönetın"},        # i->ı
            {"correct": "proje", "wrong": "proce"},            # j->c
            {"correct": "sistem", "wrong": "şistem"},          # s->ş
            {"correct": "program", "wrong": "proğram"},        # g->ğ
            {"correct": "internet", "wrong": "ınternet"},      # i->ı
            {"correct": "bilim", "wrong": "pilim"},            # b->p
            {"correct": "araştırma", "wrong": "araştırna"},    # m->n
            {"correct": "geliştirme", "wrong": "keliştirnı"},  # g->k, m->n
            {"correct": "tasarım", "wrong": "tasarın"},        # ı->ı, m->n
            {"correct": "uygulama", "wrong": "uygulana"},      # m->n
            {"correct": "analiz", "wrong": "anariz"},          # l->r
            {"correct": "sentez", "wrong": "şentez"},          # s->ş
            {"correct": "hipotez", "wrong": "hibotez"},        # p->b
            {"correct": "teori", "wrong": "teorı"},            # i->ı
            {"correct": "pratik", "wrong": "bradik"},          # p->b, t->d
            {"correct": "deneyim", "wrong": "teneyim"},        # d->t
            {"correct": "beceri", "wrong": "peçeri"},          # b->p
            {"correct": "yetenek", "wrong": "yeteneğ"},        # k->ğ
            {"correct": "başarı", "wrong": "paşarı"},          # b->p
            {"correct": "gelişim", "wrong": "kelişim"},        # g->k
            {"correct": "öğretim", "wrong": "öğretın"},        # i->ı
            {"correct": "eğitim", "wrong": "eğitın"},          # i->ı
            {"correct": "öğrenci", "wrong": "öğrenpi"}         # c->p
        ]
        
        # Kelime çiftlerini JSON string'e çevir
        words_json = json.dumps(word_pairs, ensure_ascii=False, indent=2)
        
        prompt = f"""
Yazım hatası tespit oyunu oluştur.

ADIM 1: Bu kelimelerden 5 tanesini seç:
matematik, bilgisayar, teknoloji, doktor, kahraman, merhaba, algoritma, elektronik, psikoloji, biyoloji, kimya, fizik, tarih, coğrafya, edebiyat, felsefe, sosyoloji, antropoloji, arkeoloji, mühendislik, mimarlık, hukuk, ekonomi, işletme, muhasebe, pazarlama, finans, yönetim, proje, sistem, program, internet, bilim, araştırma, geliştirme, tasarım, uygulama, analiz, sentez, hipotez, teori, pratik, deneyim, beceri, yetenek, başarı, gelişim, öğretim, eğitim, öğrenci

ADIM 2: Seçtiğin 5 kelimeden SADECE 1 TANESİNİ şu şekilde değiştir:
matematik→natematik, bilgisayar→pilgisayar, teknoloji→teknoloci, doktor→toktor, kahraman→gahraman, merhaba→nerhaba, algoritma→algoritna, elektronik→eleftronik, psikoloji→bsikoloji, biyoloji→piyoloji, kimya→ginya, fizik→fisik, tarih→tarıh, coğrafya→çoğrafya, edebiyat→edepiyat, felsefe→felşefe, sosyoloji→şosyoloji, antropoloji→antropoloci, arkeoloji→argeoloji, mühendislik→nühendislik, mimarlık→minarlık, hukuk→huguk, ekonomi→egonomi, işletme→işretme, muhasebe→muhaşebe, pazarlama→pasarlama, finans→finañs, yönetim→yönetın, proje→proce, sistem→şistem, program→proğram, internet→ınternet, bilim→pilim, araştırma→araştırna, geliştirme→keliştirnı, tasarım→tasarın, uygulama→uygulana, analiz→anariz, sentez→şentez, hipotez→hibotez, teori→teorı, pratik→bradik, deneyim→teneyim, beceri→peçeri, yetenek→yeteneğ, başarı→paşarı, gelişim→kelişim, öğretim→öğretın, eğitim→eğitın, öğrenci→öğrenpi

ADIM 3: Yanlış kelimenin hangi sırada olduğunu say (0'dan başla)

ÖRNEK:
Seç: matematik, bilgisayar, teknoloji, doktor, kahraman
Değiştir: bilgisayar→pilgisayar
Sonuç: ["matematik", "pilgisayar", "teknoloji", "doktor", "kahraman"]
İndeks: 1

5 farklı soru yap:
{{
  "questions": [
    {{"words": ["..."], "wrong_index": 0}}
  ]
}}
"""
        return prompt

    def _fix_spelling_game(self, spelling_data: dict) -> dict:
        """
        Spelling game verilerini kontrol eder ve düzeltir
        """
        words = spelling_data.get("words", [])
        wrong_index = spelling_data.get("wrong_index", 0)
        
        print(f"📝 Spelling Game Words: {words}")
        print(f"🎯 Wrong Index: {wrong_index}")
        
        # 5 kelime kontrolü
        if len(words) != 5:
            print(f"⚠️ {len(words)} kelime var, 5 olması gerekiyor")
            # Eksikse dummy kelimeler ekle veya fazlaysa kırp
            if len(words) < 5:
                words.extend([f"kelime{i}" for i in range(len(words), 5)])
            else:
                words = words[:5]
        
        # wrong_index kontrolü
        if wrong_index < 0 or wrong_index >= 5:
            print(f"⚠️ Wrong index {wrong_index} geçersiz, 2 olarak ayarlanıyor")
            wrong_index = 2
        
        corrected_data = {
            "words": words,
            "wrong_index": wrong_index
        }
        
        print(f"Final spelling data: {corrected_data}")
        return corrected_data

    async def generate_word_list(self, user_info: UserInfo) -> List[str]:
        """
        Kullanıcının ilgi alanına göre 5 rastgele Türkçe kelime üretir
        """
        prompt = self._create_word_list_prompt(user_info)
        
        async with httpx.AsyncClient(timeout=60.0) as client:
            try:
                response = await client.post(
                    f"{self.llama_url}/api/generate",
                    json={
                        "model": self.model_name,
                        "prompt": prompt,
                        "format": "json",
                        "stream": False,
                        "options": {
                            "temperature": 0.9,  # Daha çeşitli sonuçlar için
                            "top_p": 0.9
                        }
                    }
                )
                response.raise_for_status()
                
                llama_response = response.json()
                generated_text = llama_response.get("response", "")
                
                # JSON yanıtını parse et
                word_data = json.loads(generated_text)
                
                # Kelimeleri al
                words = word_data.get("words", [])
                
                # 5 kelime kontrolü
                if len(words) != 5:
                    print(f"⚠️ {len(words)} kelime var, 5 olması gerekiyor")
                    # Eksikse dummy kelimeler ekle veya fazlaysa kırp
                    if len(words) < 5:
                        words.extend([f"kelime{i}" for i in range(len(words), 5)])
                    else:
                        words = words[:5]
                
                print(f"Generated words: {words}")
                return words
                
            except httpx.RequestError as e:
                print(f"Llama RequestError: {e}")
                raise Exception(f"Llama API'sine bağlanılamıyor: {str(e)}")
            except httpx.HTTPStatusError as e:
                print(f"Llama HTTPStatusError: {e}")
                raise Exception(f"Llama API HTTP hatası: {e.response.status_code}")
            except json.JSONDecodeError as e:
                print(f"JSON Decode Error: {e}")
                print(f"Generated text: {generated_text}")
                raise Exception(f"Llama'dan gelen yanıt JSON formatında değil: {str(e)}")
            except Exception as e:
                print(f"Genel Exception: {e}")
                raise Exception(f"Beklenmeyen hata: {str(e)}")

    def _create_word_list_prompt(self, user_info: UserInfo) -> str:
        """
        Kullanıcının ilgi alanına göre kelime listesi oluşturmak için prompt
        """
        prompt = f"""
Kullanıcının ilgi alanına göre 5 rastgele Türkçe kelime üret.

Kullanıcı Bilgileri:
- Yaş Grubu: {user_info.age_group}
- İlgi Alanı: {user_info.hard_area}
- Hedef: {user_info.reading_goal}
- Motivasyon: {user_info.motivating_games}

KURALLAR:
- Tam olarak 5 adet Türkçe kelime ver.
- Kelimeler 6 adet harf olacak
- Kullanıcının ilgi alanına uygun kelimeler seç
- Yaş grubuna uygun zorluk seviyesi
- Sadece tek kelimeler (birleşik kelime yok)
- Gerçek ve anlamlı Türkçe kelimeler

JSON formatında döndür:
{{
  "words": ["kelime1", "kelime2", "kelime3", "kelime4", "kelime5"]
}}
"""
        return prompt

    async def generate_paragraph(self, user_info: UserInfo) -> List[str]:
        """
        Kullanıcının ilgi alanına göre 5 adet 4 cümlelik anlamlı paragraf üretir
        """
        prompt = self._create_paragraph_prompt(user_info)
        
        async with httpx.AsyncClient(timeout=90.0) as client:
            try:
                response = await client.post(
                    f"{self.llama_url}/api/generate",
                    json={
                        "model": self.model_name,
                        "prompt": prompt,
                        "format": "json",
                        "stream": False,
                        "options": {
                            "temperature": 0.8,  # Yaratıcı ama kontrollü
                            "top_p": 0.9
                        }
                    }
                )
                response.raise_for_status()
                
                llama_response = response.json()
                generated_text = llama_response.get("response", "")
                
                # JSON yanıtını parse et
                paragraph_data = json.loads(generated_text)
                
                # Paragrafları al
                paragraphs = paragraph_data.get("paragraphs", [])
                
                # 5 paragraf kontrolü
                if len(paragraphs) != 5:
                    print(f"⚠️ {len(paragraphs)} paragraf var, 5 olması gerekiyor")
                    # Eksikse varsayılan paragraflar ekle
                    default_paragraphs = [
                        "Ali kitap okumaya karar verdi. Kütüphaneye gitti ve bir kitap seçti. Saatlerce okuyarak hikayeye daldı. Kitabı bitirdiğinde çok mutlu oldu.",
                        "Ayşe resim yapmaya başladı. Renkli boyalarla tuvaline hayat verdi. Farklı teknikler deneyerek yeteneğini geliştirdi. Sonunda harika bir tablo ortaya çıkardı.",
                        "Mehmet bisiklet sürmeyi öğrendi. Parkta pratik yaparak denge kazandı. Zamanla hızlandı ve zorlu parkurları aşmaya başladı. Artık bisiklet sürmek onun en sevdiği aktivite oldu.",
                        "Zeynep yemek pişirmeye karar verdi. Malzemeleri hazırlayarak mutfağa geçti. Adım adım tarifi takip ederek lezzetli bir yemek hazırladı. Ailesi yemeği çok beğendi ve Zeynep gurur duydu.",
                        "Can müzik öğrenmeye başladı. Gitarını eline alarak pratik yapmaya başladı. Günlerce çalışarak melodileri öğrendi. Artık sevdiği şarkıları çalabiliyor ve çok mutlu."
                    ]
                    
                    if len(paragraphs) < 5:
                        paragraphs.extend(default_paragraphs[len(paragraphs):5])
                    else:
                        paragraphs = paragraphs[:5]
                
                print(f"Generated paragraphs: {paragraphs}")
                return paragraphs
                
            except httpx.RequestError as e:
                print(f"Llama RequestError: {e}")
                raise Exception(f"Llama API'sine bağlanılamıyor: {str(e)}")
            except httpx.HTTPStatusError as e:
                print(f"Llama HTTPStatusError: {e}")
                raise Exception(f"Llama API HTTP hatası: {e.response.status_code}")
            except json.JSONDecodeError as e:
                print(f"JSON Decode Error: {e}")
                print(f"Generated text: {generated_text}")
                raise Exception(f"Llama'dan gelen yanıt JSON formatında değil: {str(e)}")
            except Exception as e:
                print(f"Genel Exception: {e}")
                raise Exception(f"Beklenmeyen hata: {str(e)}")

    def _create_paragraph_prompt(self, user_info: UserInfo) -> str:
        """
        Kullanıcının ilgi alanına göre paragraf oluşturmak için prompt
        """
        prompt = f"""
Kullanıcının ilgi alanına göre 5 adet farklı konuda 4 cümlelik paragraf yaz.

Kullanıcı Bilgileri:
- Yaş Grubu: {user_info.age_group}
- Zorluk Çektiği Alanı: {user_info.hard_area}
- Hedef: {user_info.reading_goal}
- Motivasyon: {user_info.motivating_games}

KURALLAR:
- TAM OLARAK 5 adet paragraf oluştur
- Her paragraf TAM OLARAK 4 cümle olmalı
- Her paragrafın cümleleri MANTIKLI BİR EYLEM AKIŞI olmalı:
  * 1. Cümle: Hazırlık (bir şeye hazırlanma, karar verme)
  * 2. Cümle: Eylemin başlaması (ilk adım, hareket)
  * 3. Cümle: Gelişim/İlerleme (eylemde yaşanan değişim, zorluk/başarı)
  * 4. Cümle: Sonuç/Bitiş (eylemden çıkan sonuç)
- Her paragraf farklı bir konuda olmalı
- Her cümle kronolojik sırada olmalı ki kullanıcı doğru sırayı bulabilsin
- Örnek konular: kitap okuma, resim yapma, bisiklet sürme, yemek pişirme, bahçe işleri, spor yapma, müzik dinleme, seyahat etme, dans etme, oyun oynama
- Sadece Türkçe yaz
- Her paragrafın cümleleri birbirini tamamlamalı

JSON formatında döndür:
{{
  "paragraphs": [
    "İlk paragrafın ilk cümlesi, İkinci cümle. Üçüncü cümle. Dördüncü cümle.",
    "İkinci paragrafın ilk cümlesi, İkinci cümle. Üçüncü cümle. Dördüncü cümle.",
    "Üçüncü paragrafın ilk cümlesi, İkinci cümle. Üçüncü cümle. Dördüncü cümle.",
    "Dördüncü paragrafın ilk cümlesi, İkinci cümle. Üçüncü cümle. Dördüncü cümle.",
    "Beşinci paragrafın ilk cümlesi, İkinci cümle. Üçüncü cümle. Dördüncü cümle."
  ]
}}
"""
        return prompt

    async def generate_analysis(self, user_info, user_statistics) -> str:
        """
        Kullanıcı bilgileri ve istatistiklerini analiz ederek kişiselleştirilmiş rapor üretir
        """
        prompt = self._create_analysis_prompt(user_info, user_statistics)
        
        async with httpx.AsyncClient(timeout=90.0) as client:
            try:
                response = await client.post(
                    f"{self.llama_url}/api/generate",
                    json={
                        "model": self.model_name,
                        "prompt": prompt,
                        "format": "json",
                        "stream": False,
                        "options": {
                            "temperature": 0.7,  # Daha objektif analiz için
                            "top_p": 0.8
                        }
                    }
                )
                response.raise_for_status()
                
                llama_response = response.json()
                generated_text = llama_response.get("response", "")
                
                # JSON yanıtını parse et
                analysis_data = json.loads(generated_text)
                
                # Analizi al
                analysis = analysis_data.get("analysis", "")
                
                if not analysis.strip():
                    print("⚠️ Boş analiz alındı, varsayılan analiz kullanılıyor")
                    analysis = "Kullanıcının performansı değerlendirildi. Düzenli çalışma ile gelişim gösterilebilir. Güçlü yönleri desteklenmeli, zayıf alanlar üzerinde odaklanılmalı. Motivasyon sürekli yüksek tutulmalıdır."
                
                print(f"Generated analysis: {analysis}")
                return analysis
                
            except httpx.RequestError as e:
                print(f"Llama RequestError: {e}")
                raise Exception(f"Llama API'sine bağlanılamıyor: {str(e)}")
            except httpx.HTTPStatusError as e:
                print(f"Llama HTTPStatusError: {e}")
                raise Exception(f"Llama API HTTP hatası: {e.response.status_code}")
            except json.JSONDecodeError as e:
                print(f"JSON Decode Error: {e}")
                print(f"Generated text: {generated_text}")
                raise Exception(f"Llama'dan gelen yanıt JSON formatında değil: {str(e)}")
            except Exception as e:
                print(f"Genel Exception: {e}")
                raise Exception(f"Beklenmeyen hata: {str(e)}")

    def _create_analysis_prompt(self, user_info, user_statistics) -> str:
        """
        Kullanıcı bilgileri ve istatistiklerini analiz etmek için prompt
        """
        prompt = f"""
Disleksik bir öğrencinin profil bilgileri ve performans istatistiklerini analiz et. Kişiselleştirilmiş, yapıcı ve motive edici bir analiz raporu yaz.

KULLANICI BİLGİLERİ:
- Yaş Grubu: {user_info.age_group}
- Zorluk Alanı: {user_info.hard_area}
- Hedef: {user_info.reading_goal}
- Tanı Durumu: {user_info.diagnosis_time}
- Sevdiği Oyunlar: {user_info.motivating_games}
- Uzman Desteği: {user_info.working_with_professional}

PERFORMANS İSTATİSTİKLERİ:
- Toplam Oyun: {user_statistics.total_games_played}
- Fonolojik Oyun Başarı: %{user_statistics.phonological_success_rate}
- Yazım Oyunu Başarı: %{user_statistics.spelling_success_rate}
- Kelime Listesi Oyunu Başarı: %{user_statistics.word_list_success_rate}
- Paragraf Oyunu Başarı: %{user_statistics.paragraph_success_rate}

GÖREV:
Bu bilgileri sentezleyerek 4-5 cümlelik profesyonel bir analiz yaz. Şunları içer:
1. Mevcut durumun objektif değerlendirmesi
2. Güçlü yönlerin vurgulanması
3. Gelişim alanlarının belirlenmesi
4. Konstruktif öneriler ve motivasyon

KURALLAR:
- 3. ŞAHIS (objektif gözlemci) bakış açısı kullan
- "Kullanıcının...", diye başla
- "...edilmesi önerilir", "...yoğunlaşılması gerekir" gibi pasif yapılar kullan
- Profesyonel ve objektif dil kullan
- Pozitif ve motive edici ol
- Somut verilerden örnekler ver
- Sadece Türkçe yaz
- Eleştirel değil, yapıcı ol

ÖRNEK YAZIM TARZI:
"Kullanıcının 45 oyunluk deneyiminde %72.5 fonolojik başarı oranı göze çarpmaktadır. Kelime listesi alanında %85.2 gibi yüksek bir performans sergilenmesi güçlü yönlerini ortaya koymaktadır. Paragraf alanında %79.8 başarı oranı olduğundan bu alanda daha fazla practice yapılması önerilir. Genel olarak istikrarlı bir gelişim trendi gösterilmektedir."

JSON formatında döndür:
{{
  "analysis": "Kullanıcının performans analizi burada yer alır. Objektif bir değerlendirme sunulur ve gelişim alanları belirlenir. Güçlü yönler vurgulanır ve gelecek için öneriler sunulur."
}}
"""
        return prompt

    async def generate_roadmap(self, user_info) -> dict:
        """
        Kullanıcı bilgilerine göre kişiselleştirilmiş yol haritası oluşturur
        """
        prompt = self._create_roadmap_prompt(user_info)
        
        async with httpx.AsyncClient(timeout=90.0) as client:
            try:
                response = await client.post(
                    f"{self.llama_url}/api/generate",
                    json={
                        "model": self.model_name,
                        "prompt": prompt,
                        "format": "json",
                        "stream": False,
                        "options": {
                            "temperature": 0.6,  # Daha tutarlı plan için
                            "top_p": 0.8
                        }
                    }
                )
                response.raise_for_status()
                
                llama_response = response.json()
                generated_text = llama_response.get("response", "")
                
                # JSON yanıtını parse et
                roadmap_data = json.loads(generated_text)
                
                # Varsayılan yol haritası
                if not roadmap_data or not roadmap_data.get("daily_plans"):
                    print("⚠️ Boş yol haritası alındı, varsayılan plan kullanılıyor")
                    roadmap_data = {
                        "daily_plans": [
                            {"day": 1, "phonological_games": 2, "spelling_games": 1, "word_exercises": 1, "reading_time": 10},
                            {"day": 2, "phonological_games": 2, "spelling_games": 1, "word_exercises": 1, "reading_time": 10},
                            {"day": 3, "phonological_games": 3, "spelling_games": 2, "word_exercises": 1, "reading_time": 15},
                            {"day": 4, "phonological_games": 2, "spelling_games": 2, "word_exercises": 2, "reading_time": 15},
                            {"day": 5, "phonological_games": 3, "spelling_games": 2, "word_exercises": 2, "reading_time": 20},
                            {"day": 6, "phonological_games": 2, "spelling_games": 1, "word_exercises": 1, "reading_time": 10},
                            {"day": 7, "phonological_games": 1, "spelling_games": 1, "word_exercises": 1, "reading_time": 5}
                        ],
                        "total_duration_days": 7,
                        "focus_areas": ["Hece tanıma", "Yazım doğruluğu", "Kelime dağarcığı"]
                    }
                
                print(f"Generated roadmap: {roadmap_data}")
                return roadmap_data
                
            except httpx.RequestError as e:
                print(f"Llama RequestError: {e}")
                raise Exception(f"Llama API'sine bağlanılamıyor: {str(e)}")
            except httpx.HTTPStatusError as e:
                print(f"Llama HTTPStatusError: {e}")
                raise Exception(f"Llama API HTTP hatası: {e.response.status_code}")
            except json.JSONDecodeError as e:
                print(f"JSON Decode Error: {e}")
                print(f"Generated text: {generated_text}")
                raise Exception(f"Llama'dan gelen yanıt JSON formatında değil: {str(e)}")
            except Exception as e:
                print(f"Genel Exception: {e}")
                raise Exception(f"Beklenmeyen hata: {str(e)}")

    def _create_roadmap_prompt(self, user_info) -> str:
        """
        Kullanıcı bilgilerine göre yol haritası oluşturmak için prompt
        """
        prompt = f"""
Disleksik bir öğrenci için kişiselleştirilmiş 7 günlük yol haritası oluştur.

KULLANICI BİLGİLERİ:
- Yaş Grubu: {user_info.age_group}
- Zorluk Alanı: {user_info.hard_area}
- Hedef: {user_info.reading_goal}
- Tanı Durumu: {user_info.diagnosis_time}
- Sevdiği Oyunlar: {user_info.motivating_games}
- Uzman Desteği: {user_info.working_with_professional}

GÖREV:
7 günlük günlük egzersiz planı oluştur. Her gün için:
- Fonolojik oyun sayısı (1-5 arası)
- Yazım oyunu sayısı (1-4 arası)  
- Kelime egzersizi sayısı (1-3 arası)
- Okuma süresi dakika (5-30 arası)

KURALLAR:
- İlk günler daha az, ilerleyen günlerde artırarak zorluk
- Hafta sonu daha hafif program
- Kullanıcının zorluk alanına odaklan
- Yaş grubuna uygun yoğunluk
- Motivasyonu koruyacak çeşitlilik

ODAK ALANLARI:
Kullanıcının zorluk alanına göre odaklanılacak alanları belirle:
- Hece tanıma, Ses-harf eşleştirme, Yazım doğruluğu, Kelime dağarcığı, vb.

JSON formatında döndür:
{{
  "daily_plans": [
    {{
      "day": 1,
      "phonological_games": 2,
      "spelling_games": 1,
      "word_exercises": 1,
      "reading_time": 10
    }}
  ],
  "total_duration_days": 7,
  "focus_areas": ["Hece tanıma", "Yazım doğruluğu"]
}}

TAM OLARAK 7 günlük plan oluştur!
"""
        return prompt
