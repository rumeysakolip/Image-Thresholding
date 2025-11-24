import cv2
import numpy as np
import matplotlib.pyplot as plt
import os
import time

# ===========================================================
#  OTSU ALGORİTMASI İLE GLOBAL EŞİKLEME (Tek seviye)
# ===========================================================

# 1️⃣ Giriş görüntü yolu ve çıktı klasörleri ayarları
image_path = os.path.join(os.path.dirname(__file__), "test-images", "img5.jpg")  # Örnek görüntü
output_dir = "otsu-images"
histo_dir = "histograms"
os.makedirs(output_dir, exist_ok=True)
os.makedirs(histo_dir, exist_ok=True)
base_name = os.path.splitext(os.path.basename(image_path))[0]

start_time = time.time()

# 2️⃣ Görüntüyü gri tonlu olarak yükle
img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
if img is None:
    raise FileNotFoundError(f"Görüntü yüklenemedi. Dosya yolu hatalı olabilir: {image_path}")
h, w = img.shape
print(f"Görüntü bilgileri - Adı: {os.path.basename(image_path)}, Boyutu: {w}x{h}, Piksel aralığı: {img.min()}–{img.max()}")

# 3️⃣ Histogram hesapla ve Otsu optimum eşik değerini bul
hist = cv2.calcHist([img], [0], None, [256], [0, 256]).flatten().astype(int)
total_pixels = img.size
prob = hist / float(total_pixels)                     # Her seviye için olasılık
cumulative_prob = np.cumsum(prob)                     # ω0(t) – arka plan ağırlığı (t dahil)
cumulative_mean = np.cumsum(prob * np.arange(256))    # Kümülatif ortalama değerler
global_mean = cumulative_mean[-1]                     # Tüm görüntünün ortalama gri değeri (μ_T)
# Sınıflar arası varyansın karesi (σ_b^2) tüm olası eşikler için vektörel hesaplama
sigma_b_squared = (global_mean * cumulative_prob - cumulative_mean) ** 2 / (cumulative_prob * (1 - cumulative_prob) + 1e-6)
sigma_b_squared[np.isnan(sigma_b_squared)] = 0        # Tanımsız değerleri 0 yap (bölme 0 ise)
optimal_threshold = int(np.argmax(sigma_b_squared))   # Maksimum σ_b^2 için indeks (eşik):contentReference[oaicite:7]{index=7}
print(f"Optimum eşik değeri (Otsu): {optimal_threshold}")

# 4️⃣ Histogram grafiğini oluştur ve kaydet
plt.figure(figsize=(8, 4))
plt.hist(img.ravel(), bins=256, range=(0, 256), color='gray')
plt.axvline(optimal_threshold, color='red', linestyle='--', label=f'T = {optimal_threshold}')
plt.title("Gri Seviye Histogramı ve Otsu Eşiği")
plt.xlabel("Piksel Değeri")
plt.ylabel("Frekans")
plt.legend()
hist_path = os.path.join(histo_dir, f"{base_name}_histogram.png")
plt.savefig(hist_path, dpi=200, bbox_inches='tight')
plt.close()

# 5️⃣ Eşik değeri ile ikili görüntüyü oluştur ve kaydet
_, binary_img = cv2.threshold(img, optimal_threshold, 255, cv2.THRESH_BINARY)
binary_path = os.path.join(output_dir, f"{base_name}_otsu_binary.png")
cv2.imwrite(binary_path, binary_img)

# 6️⃣ Sonuçları bildir ve süreyi hesapla
end_time = time.time()
print("Global Otsu eşikleme tamamlandı ✅")
print(f"Histogram kaydedildi: {hist_path}")
print(f"Binary görüntü kaydedildi: {binary_path}")
print(f"Toplam süre: {(end_time - start_time)*1000:.2f} ms")
