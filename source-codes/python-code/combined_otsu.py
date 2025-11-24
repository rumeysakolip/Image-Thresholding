import cv2
import matplotlib.pyplot as plt
# Aynı dizindeki modülleri içe aktar
import global_otsu
import local_otsu

# 1️⃣ Örnek görüntü ve parametreler
image_path = "test-images/img5.jpg"   # İşlenecek görüntü
block_size = 128                     # Lokal Otsu için blok boyutu

# 2️⃣ Global Otsu algoritmasını uygula
print("Global Otsu eşikleme uygulanıyor...")
threshold, binary_image = global_otsu.global_otsu(image_path)  # Fonksiyon çıktısı: eşik ve ikili görüntü
print(f"Global Otsu optimum eşiği: {threshold}")

# 3️⃣ Lokal Otsu algoritmasını uygula
print("Lokal Otsu eşikleme uygulanıyor...")
local_image = local_otsu.local_otsu(image_path, block_size)    # Fonksiyon çıktısı: eşiklenmiş görüntü

# 4️⃣ Sonuçları karşılaştırmalı olarak görselleştir
original_gray = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
plt.figure(figsize=(15, 5))
plt.subplot(1, 3, 1)
plt.title("Orijinal Gri")
plt.imshow(original_gray, cmap='gray')
plt.axis('off')
plt.subplot(1, 3, 2)
plt.title("Global Otsu")
plt.imshow(binary_image, cmap='gray')
plt.axis('off')
plt.subplot(1, 3, 3)
plt.title(f"Lokal Otsu (blok={block_size})")
plt.imshow(local_image, cmap='gray')
plt.axis('off')
plt.tight_layout()
plt.show()
