import cv2
import numpy as np
import matplotlib.pyplot as plt
import os
import time

start_time = time.time()

# Görüntü dosya yolunu ayarla
image_path = r"C:\Users\rumey\Documents\VSCode-file(s)\Python\img3.jpg"  # Burada ilgili görüntü yolunu yaz
output_dir = os.path.dirname(image_path)

try:
    # Görüntüyü yükleme
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        raise FileNotFoundError("Görüntü yüklenemedi. Dosya yolu hatalı olabilir.")

    # Görüntü bilgilerini yazdırma
    h, w = img.shape
    print("Görüntünün")
    print(f"Adı: {os.path.basename(image_path)}")
    print(f"Boyutu: {w} x {h}")
    print(f"Pixel Değer Aralığı: {img.min()}-{img.max()}")
except Exception as e:
    print(f"[HATA - GÖRÜNTÜ ALMA] {e}")

print("Eşikleme işlemi başlatılıyor...")

try:
    # Histogram analizi
    hist = cv2.calcHist([img], [0], None, [256], [0, 256]).flatten().astype(int)
    pixel_count = {i: hist[i] for i in range(256)}

    # Histogram grafiği oluşturma
    plt.figure()
    plt.title("Histogram")
    plt.xlabel("Pixel Değerleri")
    plt.ylabel("Frekans")
    plt.bar(pixel_count.keys(), pixel_count.values())
    hist_path = os.path.join(output_dir, "histogram3.png")
    plt.savefig(hist_path)
    plt.close()
    
    # Histogramı açma
    os.startfile(hist_path)
except Exception as e:
    print(f"[HATA - HISTOGRAM] {e}")

try:
    # Otsu mantığı ile varyans hesaplama
    total_pixels = img.size
    prob = hist / total_pixels
    cumulative_prob = np.cumsum(prob)
    cumulative_mean = np.cumsum(prob * np.arange(256))
    global_mean = cumulative_mean[-1]

    sigma_b_squared = (global_mean * cumulative_prob - cumulative_mean) ** 2 / (cumulative_prob * (1 - cumulative_prob) + 1e-6)
    sigma_b_squared[np.isnan(sigma_b_squared)] = 0

    optimal_threshold = np.argmax(sigma_b_squared)
    max_variance = sigma_b_squared[optimal_threshold]

    print(f"Eşsik değeri  ~~ {optimal_threshold} ~~")
except Exception as e:
    print(f"[HATA - VARYANS HESAPLAMA] {e}")

try:
    # Eşik uygulama (bimodal görüntü)
    _, binary_img = cv2.threshold(img, optimal_threshold, 255, cv2.THRESH_BINARY)
    binary_path = os.path.join(output_dir, "bimodal3.png")
    cv2.imwrite(binary_path, binary_img)
    
    # Bimodal görüntüyü açma
    os.startfile(binary_path)
except Exception as e:
    print(f"[HATA - BİMODAL OLUŞTURMA] {e}")

end_time = time.time()
elapsed_time_ms = (end_time - start_time) * 1000
print(f"Toplam süre: {elapsed_time_ms:.2f} ms")
print("İŞLEM SONA ERDİ")
