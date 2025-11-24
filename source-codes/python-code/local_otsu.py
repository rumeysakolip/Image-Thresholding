import cv2
import numpy as np
import matplotlib.pyplot as plt
import os
import time

# ===========================================================
#  YEREL (ADAPTİF) OTSU EŞİKLEME – TAM KOD
# ===========================================================

# 1️⃣ Giriş ayarları (görüntü yolu ve çıktı klasörleri)
image_path = os.path.join(os.path.dirname(__file__), "test-images", "img5.jpg")  # Örnek görüntü
output_dir = "otsu-images"
histo_dir  = "histograms"
os.makedirs(output_dir, exist_ok=True)
os.makedirs(histo_dir, exist_ok=True)
base_name = os.path.splitext(os.path.basename(image_path))[0]

# Blok boyutu (her blok için ayrı eşik hesaplanacak)
block_size = 128

start_time = time.time()

# 2️⃣ Görüntüyü yükle ve gri tonlamaya çevir
img_color = cv2.imread(image_path)
if img_color is None:
    raise FileNotFoundError(f"Görüntü okunamadı. Dosya yolunu kontrol et: {image_path}")
gray = cv2.cvtColor(img_color, cv2.COLOR_BGR2GRAY)
h, w = gray.shape
print(f"Görüntü boyutu: {w}x{h} piksel, Parlaklık aralığı: {gray.min()}–{gray.max()}")

# Gürültüyü azaltmak için hafif bulanıklaştırma (Gaussian blur)
gray = cv2.GaussianBlur(gray, (5, 5), 0)
# İsteğe bağlı: Gri görüntüyü kaydet (kontrol amaçlı)
gray_save_path = os.path.join(output_dir, f"{base_name}_gray.png")
cv2.imwrite(gray_save_path, gray)
print(f"Gri tonlamalı (bulanıklaştırılmış) görüntü kaydedildi: {gray_save_path}")

# 3️⃣ Global histogram oluştur ve kaydet (tüm görüntü için)
hist = cv2.calcHist([gray], [0], None, [256], [0, 256]).flatten().astype(int)
plt.figure()
plt.title("Global Histogram")
plt.xlabel("Piksel Değerleri")
plt.ylabel("Frekans")
plt.bar(np.arange(256), hist, color='gray')
global_hist_path = os.path.join(histo_dir, f"{base_name}_global_hist.png")
plt.savefig(global_hist_path, dpi=150, bbox_inches='tight')
plt.close()
print(f"Global histogram kaydedildi: {global_hist_path}")

# 4️⃣ Yerel Otsu eşikleme uygulama (her blok için)
local_result = np.zeros_like(gray)    # Sonuç ikili görüntü (başlangıçta siyah)
local_thresholds = []                # Her bloğun eşik değerlerini saklamak için liste

for y in range(0, h, block_size):
    for x in range(0, w, block_size):
        block = gray[y:y+block_size, x:x+block_size]
        if block.size < 10:
            continue  # Çok küçük blok kalmadıysa atla

        # Blok içi histogram ve Otsu eşik hesaplaması
        hist_block = cv2.calcHist([block], [0], None, [256], [0, 256]).flatten().astype(int)
        total = block.size
        prob = hist_block / float(total)
        cum_prob = np.cumsum(prob)
        cum_mean = np.cumsum(prob * np.arange(256))
        mean = cum_mean[-1]  # blok içi ortalama gri değer
        sigma_b = (mean * cum_prob - cum_mean) ** 2 / (cum_prob * (1 - cum_prob) + 1e-6)
        sigma_b[np.isnan(sigma_b)] = 0
        local_thresh = int(np.argmax(sigma_b))       # blok için en iyi eşik:contentReference[oaicite:14]{index=14}
        local_thresholds.append(local_thresh)

        # Blok için binary eşikleme uygula
        _, block_binary = cv2.threshold(block, local_thresh, 255, cv2.THRESH_BINARY)
        local_result[y:y+block_size, x:x+block_size] = block_binary

print(f"Yerel Otsu eşikleme tamamlandı (blok boyutu = {block_size})")

# Kenar etkilerini azaltmak için sonuç üzerinde filtre (opsiyonel)
local_result = cv2.medianBlur(local_result, 5)

# 5️⃣ Yerel eşik değerleri dağılım histogramını oluştur ve kaydet
plt.figure(figsize=(8, 4))
plt.hist(local_thresholds, bins=range(0, 256, 5), color='gray', edgecolor='black')
plt.title(f"Lokal Otsu Eşik Değerleri Dağılımı (blok={block_size})")
plt.xlabel("Eşik Değeri")
plt.ylabel("Blok Sayısı")
mean_thresh = float(np.mean(local_thresholds))
plt.axvline(mean_thresh, color='red', linestyle='--', linewidth=1.5, label=f"Ortalama T = {mean_thresh:.1f}")
plt.legend()
local_thresh_hist_path = os.path.join(histo_dir, f"{base_name}_local_thresholds_hist.png")
plt.savefig(local_thresh_hist_path, dpi=200, bbox_inches='tight')
plt.close()
print(f"Lokal eşik değerleri histogramı kaydedildi: {local_thresh_hist_path}")
print(f"Yerel ortalama eşik değeri: {mean_thresh:.2f}")

# 6️⃣ Eşiklenmiş görüntüyü kaydet
local_result_path = os.path.join(output_dir, f"{base_name}_local_otsu.png")
cv2.imwrite(local_result_path, local_result)
print(f"Yerel Otsu ile eşiklenmiş görüntü kaydedildi: {local_result_path}")

# 7️⃣ Sonuç görselleştirme (orijinal vs yerel eşik) ve süre hesabı
plt.figure(figsize=(10, 5))
plt.subplot(1, 2, 1)
plt.title("Orijinal Gri (Blurred)")
plt.imshow(gray, cmap='gray')
plt.axis('off')
plt.subplot(1, 2, 2)
plt.title(f"Yerel Otsu (blok={block_size})")
plt.imshow(local_result, cmap='gray')
plt.axis('off')
plt.tight_layout()
plt.show()

end_time = time.time()
print(f"Toplam süre: {(end_time - start_time)*1000:.2f} ms")
print("✅ Tüm işlem başarıyla tamamlandı.")
