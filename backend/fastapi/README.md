# 🎯 DysLex AI - Disleksik Bireyler İçin Eğitim Platformu

**Yapay zeka destekli, kişiselleştirilmiş disleksi eğitim oyunları**

Bu proje, disleksik bireyler için özel olarak tasarlanmış, Llama AI modeli ile desteklenen kapsamlı bir eğitim platformudur. Fonolojik disleksi odaklı 6 farklı oyun türü ile bireyselleştirilmiş öğrenme deneyimi sunar.

## 🌟 Özellikler

-  🧠 **AI Destekli İçerik**: Llama 3 modeli ile dinamik soru üretimi
-  🎮 **6 Farklı Oyun Türü**: Fonolojik, yazım, kelime, paragraf oyunları ve analiz
-  👤 **Kişiselleştirme**: Kullanıcı profiline göre özelleştirilmiş içerik
-  📊 **Performans Analizi**: Detaylı başarı takibi ve gelişim raporu
-  🗺️ **Öğrenme Yol Haritası**: 7 günlük kişisel eğitim planı
-  🌍 **Türkçe Odaklı**: Türkçe dil yapısına özel algoritma
-  ⚡ **Hızlı API**: FastAPI ile yüksek performans
-  📱 **RESTful Tasarım**: Tüm platformlarda kullanım

## 🎲 Oyun Türleri

### 1. 🔤 Fonolojik Oyun (Hece Avcısı)

-  Hedef hece tanıma ve eşleştirme
-  5 soru, 4 seçenek formatı
-  Türkçe karakter duyarlılığı

### 2. ✏️ Yazım Hatası Tespit Oyunu

-  Görsel ve fonetik benzerlik odaklı
-  Yaygın disleksi yazım hatalarını hedefler

### 3. 📚 Kelime Listesi Oyunu

-  İlgi alanına göre 6 harfli kelimeler
-  5 rastgele Türkçe kelime üretimi
-  Kelime dağarcığı geliştirme

### 4. 📖 Paragraf Oyunu

-  5 farklı konuda paragraf
-  Mantıklı eylem akışı (başlangıç→gelişim→sonuç)
-  Cümle sıralama için optimize edilmiş

### 5. 📈 Performans Analizi

-  4 oyun türü başarı analizi
-  Kişiselleştirilmiş gelişim raporu
-  Yapıcı öneriler ve motivasyon

### 6. 🗺️ Öğrenme Yol Haritası

-  7 günlük kişisel plan
-  Progresif zorluk artışı
-  Hafta sonu optimizasyonu

## 🚀 Hızlı Başlangıç

### Gereksinimler

-  Python 3.8+
-  Ollama (Llama3:8b modeli)
-  FastAPI ve bağımlılıklar

### Kurulum

1. **Projeyi klonlayın**

```bash
git clone <repository-url>
cd hackathon-2
```

2. **Bağımlılıkları yükleyin**

```bash
pip install -r requirements.txt
```

3. **Ollama'yı başlatın**

```bash
# Llama3:8b modelini çalıştırın
ollama run llama3:8b
```

4. **API'yi başlatın**

```bash
python main.py
```

API şu adreste çalışacak: `http://localhost:8000`

## 📊 API Dokümantasyonu

### Base URL

```
http://localhost:8000
```

### Ana Endpoint'ler

#### 🎮 Oyun Endpoint'leri

**POST** `/api/phonological-game` - Fonolojik oyun
**POST** `/api/spelling-game` - Yazım hatası tespit oyunu  
**POST** `/api/word-list` - Kelime listesi oyunu
**POST** `/api/paragraph` - Paragraf oyunu

#### 📊 Analiz Endpoint'leri

**POST** `/api/analysis` - Performans analizi
**POST** `/api/roadmap` - Öğrenme yol haritası

### 🔧 Request Format (Tüm Oyunlar)

```json
{
	"user_info": {
		"age_group": "14-17",
		"hard_area": "Hece tanıma ve ses-harf eşleştirme zorluğu",
		"reading_goal": "Takılmadan kelime okuma ve hece ayırma becerisi kazanma",
		"diagnosis_time": "6 ay önce fonolojik disleksi tanısı aldı",
		"motivating_games": "Kelime oyunları, ses eşleştirme, hızlı tanıma oyunları",
		"working_with_professional": "Özel eğitim uzmanı ile haftada 2 saat çalışıyor"
	}
}
```

### 📊 Analiz Request Format

```json
{
	"user_info": {
		/* yukarıdaki gibi */
	},
	"user_statistics": {
		"total_games_played": 45,
		"phonological_success_rate": "72.5",
		"spelling_success_rate": "68.0",
		"word_list_success_rate": "85.2",
		"paragraph_success_rate": "79.8"
	}
}
```

### 📝 Response Örnekleri

#### Fonolojik Oyun Response

```json
{
  "questions": [
      "correct_answers": [0, 2]
    }
  ]
}
```

#### Paragraf Oyunu Response

```json
{
	"paragraphs": [
		"Ali kitap okumaya karar verdi. Kütüphaneye gitti ve bir kitap seçti. Saatlerce okuyarak hikayeye daldı. Kitabı bitirdiğinde çok mutlu oldu.",
		"Ayşe resim yapmaya başladı. Renkli boyalarla tuvaline hayat verdi...",
		"..."
	]
}
```

#### Yol Haritası Response

```json
{
	"daily_plans": [
		{
			"day": 1,
			"phonological_games": 2,
			"spelling_games": 1,
			"word_exercises": 1,
			"reading_time": 10
		}
	],
	"total_duration_days": 7,
	"focus_areas": ["Hece tanıma", "Ses-harf eşleştirme"]
}
```

## 🧪 Test Etme

### Swagger UI

API dokümantasyonunu ve test arayüzünü görüntülemek için:

```
http://localhost:8000/docs
```

### Sample Request

```bash
curl -X POST "http://localhost:8000/api/phonological-game" \
     -H "Content-Type: application/json" \
     -d '{
       "user_info": {
         "age_group": "14-17",
         "hard_area": "Hece tanıma zorluğu",
         "reading_goal": "Akıcı okuma",
         "diagnosis_time": "6 ay",
         "motivating_games": "Kelime oyunları",
         "working_with_professional": "Evet"
       }
     }'
```

## 🏗️ Teknik Mimari

### Teknoloji Stack

-  **Backend**: FastAPI (Python)
-  **AI Model**: Llama 3.8B (Ollama)
-  **Validation**: Pydantic
-  **HTTP Client**: HTTPX
-  **CORS**: Enabled for all origins

### Proje Yapısı

```
├── main.py              # FastAPI uygulaması ve endpoint'ler
├── models.py            # Pydantic data modelleri
├── llama_service.py     # Llama AI entegrasyonu
├── requirements.txt     # Python bağımlılıkları
├── test_*.json         # Test verileri
└── README.md           # Dokümantasyon
```

### Özellikler

-  ✅ **Async/Await**: Yüksek performans için asenkron programlama
-  ✅ **Error Handling**: Kapsamlı hata yönetimi
-  ✅ **Validation**: Pydantic ile tip güvenliği
-  ✅ **CORS**: Cross-origin resource sharing desteği
-  ✅ **JSON Format**: Structured AI responses
-  ✅ **Turkish Support**: Türkçe karakter duyarlılığı

## 🎯 Hackathon Hedefleri

Bu proje, disleksik bireylerin eğitim sürecini desteklemek amacıyla geliştirilmiştir:

-  **🤝 Sosyal Etki**: Disleksik bireylerin okuma-yazma becerilerini geliştirme
-  **🧠 AI Innovation**: Eğitimde yapay zeka kullanımının öncülüğü
-  **  Accessibility**: Platform bağımsız kullanım imkanı
-  **🎮 Gamification**: Öğrenmeyi eğlenceli hale getirme
-  **📊 Data-Driven**: Performans verilerine dayalı kişiselleştirme

## 👨‍💻 Geliştirici

Bu proje hackathon için geliştirilmiştir. Disleksik bireyler için fark yaratmayı hedefleyen bir eğitim teknolojisi projesidir.
Farklı bir adres kullanmak için `llama_service.py` dosyasındaki URL'yi değiştirin.

## API Dokümantasyonu

Uygulama çalıştıktan sonra:

-  Swagger UI: http://localhost:8000/docs
-  ReDoc: http://localhost:8000/redoc

## Test

Örnek request:

```bash
curl -X POST "http://localhost:8000/api/phonological-game" \
  -H "Content-Type: application/json" \
  -d '{
    "user_info": {
      "age_group": "14-17",
      "hard_area": "Hece tanıma zorluğu",
      "reading_goal": "Takılmadan okuma",
      "diagnosis_time": "6 ay önce tanı aldı",
      "motivating_games": "Kelime oyunları",
      "working_with_professional": "Uzman desteği alıyor"
    }
  }'
```
