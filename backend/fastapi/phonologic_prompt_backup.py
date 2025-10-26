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