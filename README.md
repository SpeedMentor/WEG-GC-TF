# WEG-GC-TF
Bu repoda, WEG-GC-TF çalışması ile alakalı Terraform, Kubernetes ve Helm dosyaları bulunmaktadır.
Buna göre, bu dosyalar kullanılarak ve ek ayarlar yapılarak, istenilen operasyonlar gerçekleştirilmiştir.
Detaylı case study raporunu yine repo içerisinde bulabilirsiniz.

# GCP Kubernetes Altyapısı ve Uygulama Dağıtımı

Bu depo, Google Cloud Platform (GCP) üzerinde Kubernetes ortamı kurulumunu ve örnek bir uygulamanın dağıtımını otomatikleştirmek için altyapı kodlarını ve manifest dosyalarını içerir.  
Terraform ile GKE (Google Kubernetes Engine) kümesi kurulur, örnek uygulama Kubernetes manifestleriyle dağıtılır ve Prometheus-Grafana, KEDA, Istio gibi üçüncü parti servisler Helm chart’ları ile entegre edilir.

---

## Dizin Yapısı
.
├── terraform/ # GCP ve GKE için altyapı kodları
│ ├── provider.tf
│ └── main.tf
│
├── k8s/ # Uygulama dağıtım ve ölçekleme manifestleri
│ ├── deployment.yaml
│ ├── service.yaml
│ ├── hpa.yaml
│ └── scalingobject.yaml
│
├── helm-charts/ # Üçüncü parti Helm chart klasörleri
│ ├── kube-prometheus-stack/
│ ├── keda/
│ ├── istiod/
│ └── gateway/
│
└── WEG - Case Study - Eren Fidan.pdf
└── README.md

---

## Başlarken

# 1. Terraform ile Altyapı Kurulumu

`terraform/` klasörüne girerek Terraform komutlarını çalıştırın:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```
Bu adımlar, GCP üzerinde bir GKE kümesi ve bağlı kaynakları oluşturacaktır.
Not: provider.tf içindeki proje ve kimlik bilgisi ayarlarını güncelleyiniz.

# 2. Kubernetes Cluster’ına Bağlantı
Cluster erişimi için (proje ve cluster adını kendi bilgilerinizle değiştirin):
gcloud container clusters get-credentials case-cluster --region europe-west1 --project [YOUR_PROJECT_ID]

# 3. Uygulama Manifestlerini Yükleme
Kubernetes manifestlerini uygulayarak örnek uygulamayı dağıtın:
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml

Eğer KEDA ile autoscaling kullanacaksanız:
kubectl apply -f k8s/scalingobject.yaml

# 4. Helm ile Üçüncü Parti Servislerin Kurulumu
Her bir Helm chart klasörü için aşağıdaki örnekteki gibi kurulumu gerçekleştirebilirsiniz:
helm install monitoring ./helm-charts/kube-prometheus-stack -n monitoring --create-namespace
helm install keda ./helm-charts/keda -n keda --create-namespace
helm install istiod ./helm-charts/istiod -n istio-system --create-namespace
helm install istio-ingress ./helm-charts/gateway -n istio-system

İhtiyaca göre kendi values.yaml dosyalarınızı oluşturarak konfigürasyonu özelleştirebilirsiniz.

# Notlar
- provider.tf dosyasında GCP proje bilgilerinizi ve kimlik doğrulama ayarlarınızı güncelleyin.
- Uygulama manifestlerinde gerekliyse nodeSelector kullanarak pod’ların doğru node pool üzerinde çalışmasını sağlayın.
- KEDA ScaledObject kullanıyorsanız, aynı deployment için standart HPA kaydını kaldırın.
- Prometheus-Grafana, KEDA ve Istio kurulumlarında namespace’leri doğru belirleyin.
- Helm chart’lar doğrudan resmi Helm reposundan çekilmiş olup, versiyon kontrolü ve özelleştirme amacıyla klasör olarak eklenmiştir.

# Faydalı Komutlar
kubectl get pods -A
kubectl get svc -A
kubectl get hpa
helm list -A
