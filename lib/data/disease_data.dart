import '../models/disease_info.dart';

/// Database referensi statis untuk 5 kelas daun padi
/// Berdasarkan pustaka perlindungan tanaman padi dan standar Balai Besar Penelitian Tanaman Padi (BBPadi / BRIN).
class DiseaseData {
  static const Map<String, DiseaseInfo> diseases = {
    'Bacterial_Leaf_Blight': DiseaseInfo(
      id: 'Bacterial_Leaf_Blight',
      nameId: 'Hawar Daun Bakteri (Kresek)',
      scientificName: 'Xanthomonas oryzae pv. oryzae',
      pathogenType: 'Bakteri',
      isHealthy: false,
      shortDescription:
          'Penyakit kresek atau hawar daun bakteri merupakan salah satu penyakit utama tanaman padi di Indonesia yang dapat menurunkan hasil panen secara signifikan terutama saat musim hujan.',
      symptoms: [
        'Bercak basah keabu-abuan memanjang dari ujung atau tepi helai daun.',
        'Bercak meluas dengan tepi bergelombang tidak teratur dan berubah warna menjadi kuning keputihan.',
        'Pada serangan parah (fase kresek), seluruh daun layu mengering seperti tersiram air panas.',
        'Pada pagi hari yang lembap, kadang muncul butiran eksudat bakteri berwarna kekuningan di permukaan daun yang terinfeksi.',
      ],
      favorableConditions: [
        'Kelembapan udara tinggi (> 70%) dan suhu hangat berkisar 25–34°C.',
        'Curah hujan tinggi disertai angin kencang yang memicu luka pada daun.',
        'Pemupukan nitrogen (urea) yang berlebihan tanpa diimbangi kalium (K).',
      ],
      preventionSteps: [
        'Gunakan varietas tahan (misalnya Inpari 32, Inpari 42, Ciherang Tahan Kresek).',
        'Terapkan sistem tanam jajar legowo untuk melancarkan sirkulasi udara dan sinar matahari.',
        'Atur jarak tanam agar populasi tanaman tidak terlalu rapat.',
        'Seimbangkan pemupukan: hindari kelebihan nitrogen dan cukupi dosis pupuk Kalium (KCl).',
      ],
      technicalControl: [
        'Keringkan sawah secara berkala (intermittent irrigation) untuk menekan kelembapan mikro di sekitar rumpun.',
        'Buang dan bakar sisa tanaman jerami yang terinfeksi setelah panen.',
        'Aplikasi agens hayati bakteri antagonis seperti Paenibacillus polymyxa atau Bacillus subtilis sejak persemaian.',
      ],
      chemicalControl: [
        'Bila serangan melewati ambang ekonomi, aplikasikan bakterisida berbahan aktif tembaga (Tembaga Oksiklorida / Tembaga Hidroksida) sesuai petunjuk dosis.',
        'Gunakan antibiotik tanaman seperti Kasugamisin atau Oksitetrasiklin secara bijak dan tidak berulang kali guna mencegah resistensi.',
      ],
    ),

    'Brown_Spot': DiseaseInfo(
      id: 'Brown_Spot',
      nameId: 'Bercak Cokelat',
      scientificName: 'Bipolaris oryzae (Helminthosporium oryzae)',
      pathogenType: 'Jamur',
      isHealthy: false,
      shortDescription:
          'Penyakit bercak cokelat disebabkan oleh infeksi jamur yang sering berasosiasi dengan lahan sawah dengan kesuburan tanah rendah atau kahat hara (kekurangan unsur Silika, Kalium, atau Seng).',
      symptoms: [
        'Bercak berbentuk oval atau lingkaran kecil berwarna cokelat tua pada permukaan daun.',
        'Bercak tua memiliki titik pusat berwarna kelabu keputihan dengan lingkaran halo berwarna kekuningan di sekitarnya.',
        'Bercak dapat menyebar dan menyatu sehingga menyebabkan helai daun mengering sebelum waktunya.',
        'Pada bulir padi dapat timbul bercak cokelat kehitaman (gabah kusam/beluk).',
      ],
      favorableConditions: [
        'Tanah kurang subur, berpasir, atau kekurangan hara makro/mikro (Kalium, Seng, dan Silika).',
        'Tanaman mengalami cekaman kekeringan atau drainase lahan yang buruk.',
        'Suhu udara berkisar 25–30°C dengan kelembapan relatif di atas 85%.',
      ],
      preventionSteps: [
        'Perbaiki kesuburan tanah dengan aplikasi bahan organik, pupuk kandang matang, atau kompos jerami.',
        'Lakukan pemupukan berimbang (NPK) dan tambahkan pupuk yang mengandung unsur hara mikro Seng (Zn) dan Silika (Si).',
        'Lakukan perlakuan benih (seed treatment) sebelum disemai.',
        'Kelola air sawah dengan baik, hindari tanaman mengalami kekeringan ekstrem.',
      ],
      technicalControl: [
        'Bersihkan gulma di pematang sawah yang dapat menjadi inang alternatif jamur.',
        'Lakukan pergiliran tanaman (rotasi tanaman palawija) untuk memutus siklus hidup jamur tanah.',
        'Semprotkan agens hayati seperti Trichoderma harzianum pada fase vegetatif.',
      ],
      chemicalControl: [
        'Aplikasi fungisida protektif berbahan aktif Mankozeb atau Propineb pada fase awal kemunculan gejala.',
        'Untuk pengobatan kuratif, gunakan fungisida sistemik berbahan aktif Difenokonazol, Tebukonazol, atau Azoksistrobin sesuai anjuran.',
      ],
    ),

    'Healthy': DiseaseInfo(
      id: 'Healthy',
      nameId: 'Daun Sehat',
      scientificName: 'Oryza sativa (Kondisi Normal)',
      pathogenType: 'Sehat',
      isHealthy: true,
      shortDescription:
          'Daun padi berada dalam kondisi prima tanpa indikasi gejala bercak jamur, hawar bakteri, maupun perubahan warna akibat virus patogen.',
      symptoms: [
        'Warna daun hijau segar merata, tidak terdapat pola klorosis (kuning) abnormal.',
        'Tekstur permukaan daun kokoh dan bersih dari bercak nekrotik kebasahan atau nekrosis cokelat.',
        'Pertumbuhan helai daun tegak, lentur, dan proporsional sesuai fase pertumbuhan.',
      ],
      favorableConditions: [
        'Manajemen air dan pemupukan berimbang berjalan optimal.',
        'Sinar matahari cukup dan lingkungan sawah memiliki sirkulasi udara baik.',
      ],
      preventionSteps: [
        'Lanjutkan pemeliharaan rutin, penyiangan gulma, dan pemantauan berkala kondisi air irigasi.',
        'Terapkan pemupukan berimbang sesuai fase tanaman (fase vegetatif & fase generatif).',
        'Jaga kebersihan lingkungan pematang dari gulma inang hama/vektor.',
      ],
      technicalControl: [
        'Pertahankan pengamatan mingguan terhadap daun bagian bawah dan pelepah.',
        'Dukung mikroorganisme tanah dengan menjaga kandungan bahan organik lahan.',
      ],
      chemicalControl: [
        'Tidak diperlukan tindakan pestisida/kimiawi saat tanaman dalam kondisi sehat.',
      ],
    ),

    'Leaf_Blast': DiseaseInfo(
      id: 'Leaf_Blast',
      nameId: 'Blas Daun',
      scientificName: 'Pyricularia oryzae (Magnaporthe oryzae)',
      pathogenType: 'Jamur',
      isHealthy: false,
      shortDescription:
          'Penyakit blas daun merupakan salah satu penyakit jamur paling merusak pada tanaman padi yang dapat berkembang sangat cepat dan menular melalui spora yang terbawa angin.',
      symptoms: [
        'Bercak berbentuk belah ketupat runcing di kedua ujungnya (seperti bentuk mata atau kumparan cincin).',
        'Pusat bercak berwarna abu-abu keputihan dengan tepi berwarna cokelat kemerahan atau cokelat gelap.',
        'Bercak-bercak kecil dapat saling bergabung membentuk bidang rusak yang lebar hingga menyebabkan daun terbakar/mengering.',
        'Pada fase generatif dapat berkembang menyerang tangkai malai (blas leher/patah leher).',
      ],
      favorableConditions: [
        'Suhu malam hari yang sejuk (20–24°C) dengan embun tebal di pagi hari dan kelembapan di atas 90%.',
        'Penggunaan pupuk nitrogen (urea) dengan takaran berlebih tanpa diimbangi pupuk kalium dan fosfat.',
        'Kerapatan tanaman yang terlalu rapat menghalangi penetrasi sinar matahari.',
      ],
      preventionSteps: [
        'Gunakan varietas padi yang tahan penyakit blas (seperti Inpari 32, Inpari Blas, Towuti).',
        'Hindari penggunaan pupuk nitrogen dosis tinggi; selalu imbangi dengan pupuk P dan K.',
        'Terapkan pola tanam jajar legowo (2:1 atau 4:1) untuk mengurangi kelembapan rumpun.',
        'Perlakuan benih sebelum semai dengan fungisida protektan atau perendaman air hangat.',
      ],
      technicalControl: [
        'Sanitasi lingkungan dengan membakar sisa tanaman yang terinfeksi berat agar spora tidak menular ke pertanaman berikutnya.',
        'Atur tata air agar tanah tidak tergenang terlalu dalam terus menerus.',
        'Aplikasi agens antagonis seperti Trichoderma sp. atau Pseudomonas fluorescens.',
      ],
      chemicalControl: [
        'Aplikasi fungisida berbahan aktif Trisiklazol, Isoprotiolan, atau Karbendazim jika bercak blas mulai muncul.',
        'Penyemprotan fungisida sistemik kombinasi Azoksistrobin + Difenokonazol untuk perlindungan optimal hingga masa keluar malai.',
      ],
    ),

    'Tungro': DiseaseInfo(
      id: 'Tungro',
      nameId: 'Penyakit Tungro',
      scientificName: 'Rice Tungro Bacilliform Virus (RTBV) & RTSV',
      pathogenType: 'Virus',
      isHealthy: false,
      shortDescription:
          'Tungro adalah penyakit viral kompleks yang ditularkan oleh serangga vektor Wereng Hijau (Nephotettix virescens). Penyakit ini menyebabkan tanaman kerdil dan daun menguning oranye.',
      symptoms: [
        'Warna daun berubah kuning cerah hingga kuning kejinggaan dimulai dari ujung dan tepi daun yang lebih tua.',
        'Tanaman mengalami kekerdilan nyata (stunting) dengan jumlah anakan yang berkurang drastis.',
        'Daun muda sering terpelintir atau memiliki corak belang (mottling) bergaris pucat.',
        'Malai yang terbentuk pendek, tidak keluar sempurna, dan bulir hampa.',
      ],
      favorableConditions: [
        'Populasi serangga vektor wereng hijau yang tinggi di sekitar pertanaman.',
        'Waktu tanam yang tidak serentak dalam satu hamparan sawah (memfasilitasi migrasi vektor).',
        'Ketiadaan jeda tanam padi (padi terus-menerus tanpa rotasi tanaman).',
      ],
      preventionSteps: [
        'Tanam serentak dalam satu hamparan (rentang waktu maksimal 2 minggu).',
        'Tanam varietas tahan tungro atau tahan terhadap wereng hijau (misal Inpari 36 Lanrang, Inpari 37 Pupuk).',
        'Lakukan eradikasi selektif: segera cabut dan benamkan tanaman yang menunjukkan gejala awal agar tidak menjadi sumber infeksi virus.',
        'Terapkan rotasi tanaman dengan palawija untuk memutus siklus hidup wereng hijau.',
      ],
      technicalControl: [
        'Pasang perangkap lampu (light trap) untuk memantau fluktuasi populasi wereng hijau pada malam hari.',
        'Lestarikan musuh alami wereng hijau seperti laba-laba predator (Lycosa pseudoannulata) dan kumbang kubah.',
        'Hindari penyemprotan insektisida spektrum luas yang membunuh musuh alami pada awal tanam.',
      ],
      chemicalControl: [
        'Catatan: Penyakit virus tidak dapat disembuhkan dengan pestisida; tindakan kimia hanya ditujukan untuk mengendalikan vektor serangga Wereng Hijau.',
        'Jika populasi wereng hijau melebihi ambang kendali, gunakan insektisida spesifik pengatur tumbuh atau sistemik berbahan aktif Pimetrozin, Imidakloprid, atau Dinotefuran.',
      ],
    ),
  };

  /// Mendapatkan data penyakit berdasarkan ID / key label model TFLite
  static DiseaseInfo getInfo(String key) {
    return diseases[key] ??
        DiseaseInfo(
          id: key,
          nameId: key.replaceAll('_', ' '),
          scientificName: 'Tidak Diketahui',
          pathogenType: 'Lainnya',
          isHealthy: false,
          shortDescription: 'Informasi untuk kelas ini belum terdaftar di database lokal.',
          symptoms: const ['Gejala tidak teridentifikasi secara spesifik.'],
          favorableConditions: const ['Kondisi tidak diketahui.'],
          preventionSteps: const ['Konsultasikan dengan penyuluh pertanian lapangan terdekat.'],
          technicalControl: const ['Lakukan pengamatan berkala pada helai daun.'],
          chemicalControl: const ['Gunakan pestisida sesuai anjuran petugas pertanian setempat.'],
        );
  }

  /// Daftar semua 5 kelas penyakit untuk katalog ensiklopedia
  static List<DiseaseInfo> getAllDiseases() {
    return diseases.values.toList();
  }
}
