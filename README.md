# Image-Thresholding
Eşikleme, gri seviyeli bir görüntüyü ikili forma dönüştürerek nesne ve arka planı ayıran basit ama etkili bir görüntü işleme tekniğidir. Belirli bir eşik değeri seçilerek, bu değerin altındaki pikseller arka plana, üzerindekiler nesneye ait kabul edilir. Özellikle bimodal histogramlarda başarılıdır.

# Giriş
Eşikleme, görüntü işleme alanında, gri seviyeli görüntüleri ikili (binary) forma dönüştürerek nesne-arka plan ayrımı yapmada kullanılan temel bir tekniktir. Özellikle histogramı bimodal olan görsellerde etkili sonuçlar verir. Ancak sabit eşik değerleri, değişken aydınlatma ve kontrast koşullarında yetersiz kalır; bu da adaptif eşikleme ihtiyacını doğurur.  

Otsu’nun varyans analizine dayalı yöntemi ve ağırlık güncelleme algoritmaları gibi dinamik eşikleme teknikleri, sınıflar arası ayrımı maksimize etmeyi hedefler. Fakat bu algoritmalar yazılım tabanlı olduğunda, yüksek çözünürlüklü ve gerçek zamanlı sistemlerde performans kısıtlarına takılır. Bu nedenle, eşikleme işlemlerinin donanımda paralel olarak uygulanması kritik önemdedir.  

FPGA tabanlı mimariler, özelleştirilebilir yapıları ve paralel işlem yetenekleri sayesinde bu ihtiyacı karşılar. Örneğin, FPGA üzerinde tam paralel çalışan Otsu uygulamaları, yazılım çözümlerine kıyasla milisaniyelik işlem süreleri sunmaktadır.  

Bu projede, görüntü eşikleme işlemi 4 adet özel PE (Processing Element) ile paralel biçimde gerçekleştirilecektir. Görüntü verisi, ortak bellekteki FIFO tamponlar üzerinden PE’lere dağıtılacak; her PE, kendi bölgesinde histogram oluşturma, eşik hesaplama ve ikilileştirme işlemlerini bağımsız yürütüp sonuçları sıralı olarak birleştirecektir. Bu yapı, donanım seviyesinde yüksek hız, düşük gecikme ve verimli kaynak kullanımı sağlar.  

Sonuç olarak, geliştirilecek sistemle, adaptif eşikleme algoritmalarının FPGA üzerinde gerçek zamanlı ve kaynak etkin şekilde uygulanabilirliği gösterilecektir.  
## Kaynaklar
[1] https://pmc.ncbi.nlm.nih.gov/articles/PMC8234950/  
[2] https://dergipark.org.tr/tr/download/article-file/254958  
[3] https://www.ijert.org/research/adaptive-thresholding-for-image-enhancement-hardware-approach-IJERTCONV3IS01040.pdf  
[4] https://batuhandaz.medium.com/dijital-g%C3%B6r%C3%BCnt%C3%BC-i%CC%87%C5%9Fleme-image-processing-7-otsu-methodu-ve-k-means-k%C3%BCmelenmesi-23508548df9a  
