# MEMANTAU INFRASTRUKTUR DENGAN GRAFANA & PROMETHEUS
AUTOMATING PROMETHEUS AND NODE EXPORTER INSTALLATION

Panduan ini menjelaskan langkah-langkah untuk menginstal Docker, menjalankan Grafana, dan menambahkan dashboard Prometheus dengan Node Exporter.

## Langkah 1: Update dan Install Dependencies

1. Update sistem:
   ```
   sudo apt update -y
   ```

2. Install `make` dan `git`:
   ```
   sudo apt install make git -y
   ```

## Langkah 2: Clone Repositori Docker-Portainer

3. Clone repositori:
   ```
   git clone https://github.com/sectenzorg/docker-portainer
   ```

4. Masuk ke direktori `docker-portainer`:
   ```
   cd docker-portainer
   ```

## Langkah 3: Instal Docker

5. Install Docker:
   ```
   sudo make install-docker
   ```

6. Pastikan Docker terinstal:
   Periksa output untuk memastikan bahwa "Docker has been Installed" muncul.

## Langkah 4: Jalankan Grafana dengan Docker

7. Jalankan Grafana:
   ```
   sudo docker run -d --name grafana -p 3000:3000 grafana/grafana
   ```

## Langkah 5: Jalankan Skrip Automasi Prometheus dan Node Exporter

8. Download skrip dengan `curl`:
   ```
   curl -LO https://raw.githubusercontent.com/sectenzorg/diio-grafana-labs/refs/heads/master/automate-prom-node.sh
   ```

9. Berikan izin eksekusi pada skrip:
   ```
   sudo chmod +x automate-prom-node.sh
   ```

10. Jalankan skrip:
    ```
    sudo ./automate-prom-node.sh
    ```

## Langkah 6: Akses Prometheus dan Node Exporter

11. Akses Prometheus di browser:
    ```
    http://<IP_ADDRESS>:17845
    ```

12. Akses Node Exporter di browser:
    ```
    http://<IP_ADDRESS>:1322
    ```

## Langkah 7: Akses Grafana

13. Buka browser dan masukkan URL:
    ```
    http://<IP_ADDRESS>:3000
    ```
    Ganti `<IP_ADDRESS>` dengan alamat IP server Anda.

14. Login ke Grafana menggunakan kredensial default:
    - Username: `admin`
    - Password: `admin`

## Langkah 8: Tambahkan Data Source Prometheus

15. Tambahkan Data Source:
    - Klik pada ikon roda gigi (⚙️) di sidebar untuk membuka menu `Configuration`.
    - Pilih `Data Sources`, lalu klik `Add data source`.

16. Pilih Prometheus dari daftar data source.

17. Konfigurasi Prometheus:
    Masukkan URL Prometheus Anda:
    ```
    http://<IP_ADDRESS>:17845
    ```
    Ganti `<IP_ADDRESS>` dengan alamat IP server yang menjalankan Prometheus.

18. Simpan Data Source:
    Klik tombol `Save & Test` untuk memastikan Grafana dapat terhubung ke Prometheus.

## Langkah 9: Tambahkan Dashboard Prometheus

19. Buka Dashboard:
    - Klik pada ikon `+` di sidebar, lalu pilih `Import`.

20. Import Dashboard:
    Kunjungi [Grafana Dashboards](https://grafana.com/grafana/dashboards/?collector=nodeexporter&search=linux) untuk menemukan template dashboard yang sesuai. 

    Contoh ID dashboard yang dapat Anda gunakan:
    - ID 14731
    - ID 11074
    - ID 14513

    Masukkan salah satu ID ke dalam kolom import di Grafana, atau Anda bisa meng-upload file JSON jika memiliki.

21. Pilih Data Source:
    Pastikan untuk memilih data source Prometheus yang sudah Anda tambahkan sebelumnya.

22. Simpan Dashboard:
    Klik `Import` untuk menyimpan dashboard.

## Langkah 10: Pantau Data

23. Pantau Data:
    Sekarang Anda dapat melihat dan memantau metrik Node Exporter melalui dashboard Grafana yang telah Anda buat.

---

Selamat! Anda telah berhasil menyelesaikan lab ini! 🎉 Anda kini dapat memantau metrik sistem menggunakan Grafana dan Prometheus. Jika ada pertanyaan lebih lanjut, jangan ragu untuk bertanya!

---

**Fikri Maulana Mukhlis**
## References
This project was created with inspiration and references from the following sources:
- (https://github.com/sectenzorg/diio-grafana-labs)

