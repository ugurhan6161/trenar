/// Public, editable content used by the TRENAR storefront and admin dashboard.
class TrenarSiteContent {
  const TrenarSiteContent({
    required this.brand,
    required this.headline,
    required this.introduction,
    required this.phone,
    required this.email,
    required this.address,
    required this.license,
    required this.services,
    required this.fleet,
    required this.properties,
    required this.destinations,
    required this.packages,
    required this.bookingOptions,
  });

  factory TrenarSiteContent.fromJson(Map<String, dynamic> json) {
    return TrenarSiteContent(
      brand: SiteText.fromJson(json['brand'], 'brand'),
      headline: SiteText.fromJson(json['headline'], 'headline'),
      introduction: SiteText.fromJson(json['introduction'], 'introduction'),
      phone: _requiredString(json, 'phone'),
      email: _requiredString(json, 'email'),
      address: _requiredString(json, 'address'),
      license: SiteText.fromJson(json['license'], 'license'),
      services: _items(json, 'services'),
      fleet: _items(json, 'fleet'),
      properties: _items(json, 'properties'),
      destinations: _items(json, 'destinations'),
      packages: _items(json, 'packages'),
      bookingOptions: _texts(json, 'booking_options'),
    );
  }
  final SiteText brand;
  final SiteText headline;
  final SiteText introduction;
  final String phone;
  final String email;
  final String address;
  final SiteText license;
  final List<SiteContentItem> services;
  final List<SiteContentItem> fleet;
  final List<SiteContentItem> properties;
  final List<SiteContentItem> destinations;
  final List<SiteContentItem> packages;
  final List<SiteText> bookingOptions;

  static const defaultContent = TrenarSiteContent(
    brand: SiteText({'tr': 'TRENAR', 'en': 'TRENAR'}),
    headline: SiteText({
      'tr': 'Karadeniz ve Türkiye genelinde kusursuz VIP seyahat deneyimi',
      'en': 'Exceptional VIP travel across the Black Sea and Türkiye',
      'ar': 'رحلات VIP استثنائية في البحر الأسود وتركيا',
    }),
    introduction: SiteText({
      'tr':
          'Trabzon, Rize, Uzungöl, Ayder, Batum, İstanbul ve Antalya turları; '
          'Maybach ve Vito VIP transferleri, lüks konaklama ve gayrimenkul '
          'danışmanlığı.',
      'en':
          'Private tours to Trabzon, Rize, Uzungöl, Ayder, Batumi, Istanbul '
          'and Antalya, with Maybach and Vito transfers, luxury stays and '
          'real-estate advice.',
      'ar':
          'جولات خاصة إلى طرابزون وريزه وأوزونغول وآيدر وباتومي وإسطنبول '
          'وأنطاليا، مع خدمات نقل فاخرة وإقامة راقية واستشارات عقارية.',
    }),
    phone: '+90 532 789 6161',
    email: 'info@trenartravel.com',
    address: 'Pelitli Mah. Havalimanı Caddesi No:42/A, Trabzon, Türkiye',
    license: SiteText({'tr': '', 'en': '', 'ar': ''}),
    services: [
      SiteContentItem(
        title: SiteText({
          'tr': 'VIP transfer ve şoförlü ulaşım',
          'en': 'VIP transfers and chauffeur service',
          'ar': 'خدمات النقل الخاص والسائق',
        }),
        description: SiteText({
          'tr':
              'Mercedes Vito, V-Class ve Sprinter araçlarla havalimanı, şehir '
              'içi ve şehirlerarası yolculuk.',
          'en':
              'Airport, city and intercity travel in Mercedes Vito, V-Class '
              'and Sprinter vehicles.',
          'ar':
              'تنقلات من وإلى المطار وداخل المدن وبينها بسيارات مرسيدس '
              'الفاخرة.',
        }),
      ),
      SiteContentItem(
        title: SiteText({
          'tr': 'Doğa ve kültür turları',
          'en': 'Nature and culture tours',
          'ar': 'جولات الطبيعة والثقافة',
        }),
        description: SiteText({
          'tr':
              'Uzungöl, Ayder, Sümela, Batum ve İstanbul için kişiye özel '
              'gezi programları.',
          'en':
              'Tailored itineraries for Uzungöl, Ayder, Sumela, Batumi and '
              'Istanbul.',
          'ar': 'برامج سياحية مخصصة لأوزونغول وآيدر وسوميلا وباتومي وإسطنبول.',
        }),
      ),
      SiteContentItem(
        title: SiteText({
          'tr': 'Lüks konaklama ve yayla bungalovları',
          'en': 'Luxury stays and mountain bungalows',
          'ar': 'إقامات فاخرة وأكواخ جبلية',
        }),
        description: SiteText({
          'tr':
              'Anlaşmalı 5 yıldızlı oteller, özel villalar ve nehir kenarı '
              'dağ evleri.',
          'en':
              'Partner five-star hotels, private villas and riverside '
              'mountain lodges.',
          'ar': 'فنادق خمس نجوم وفلل خاصة وأكواخ جبلية على ضفاف الأنهار.',
        }),
      ),
      SiteContentItem(
        title: SiteText({
          'tr': 'Emlak ve yatırım danışmanlığı',
          'en': 'Real estate and investment advice',
          'ar': 'الاستشارات العقارية والاستثمارية',
        }),
        description: SiteText({
          'tr':
              'Trabzon, Rize, Antalya ve İstanbul’da villa, arsa ve '
              'vatandaşlık danışmanlığı.',
          'en':
              'Villa, land and citizenship guidance in Trabzon, Rize, Antalya '
              'and Istanbul.',
          'ar':
              'استشارات الفلل والأراضي والجنسية في طرابزون وريزه وأنطاليا '
              'وإسطنبول.',
        }),
      ),
      SiteContentItem(
        title: SiteText({
          'tr': 'Kiralık araç ve grup taşımacılığı',
          'en': 'Car rental and group transport',
          'ar': 'تأجير السيارات والنقل الجماعي',
        }),
        description: SiteText({
          'tr':
              'Şoförsüz sedan ve SUV seçenekleri, midibüs ve büyük otobüs '
              'tahsisi.',
          'en':
              'Self-drive sedans and SUVs, plus minibuses and coaches for '
              'groups.',
          'ar': 'سيارات سيدان ودفع رباعي للتأجير الذاتي، وحافلات للمجموعات.',
        }),
      ),
    ],
    bookingOptions: [
      SiteText({
        'tr': 'Havalimanı VIP karşılama (isimli bordo halı)',
        'en': 'VIP airport greeting with a name board',
        'ar': 'استقبال VIP في المطار بلوحة اسم',
      }),
      SiteText({
        'tr': 'Seyahat ve sağlık sigortası',
        'en': 'Travel and health insurance',
        'ar': 'تأمين السفر والصحة',
      }),
      SiteText({
        'tr': '5G SIM kart veya taşınabilir Wi-Fi',
        'en': '5G SIM card or portable Wi-Fi',
        'ar': 'شريحة 5G أو واي فاي محمول',
      }),
      SiteText({
        'tr': 'Yeminli tercüman ve özel asistan',
        'en': 'Certified interpreter and personal assistant',
        'ar': 'مترجم معتمد ومساعد شخصي',
      }),
      SiteText({
        'tr': 'Drone ve fotoğraf/video çekimi',
        'en': 'Drone and photo/video service',
        'ar': 'تصوير جوي وتصوير فوتوغرافي وفيديو',
      }),
      SiteText({
        'tr': 'Gurme veya helal yemek organizasyonu',
        'en': 'Gourmet or halal meal arrangements',
        'ar': 'ترتيبات وجبات حلال أو فاخرة',
      }),
      SiteText({
        'tr': 'Bebek/çocuk koltuğu ve erişilebilirlik desteği',
        'en': 'Child seat and accessibility assistance',
        'ar': 'مقعد أطفال ومساعدة لذوي الاحتياجات',
      }),
      SiteText({
        'tr': 'Türk hamamı ve VIP SPA',
        'en': 'Traditional hammam and VIP spa',
        'ar': 'حمام تركي وسبا VIP',
      }),
      SiteText({
        'tr': 'Özel yat ve tekne turu',
        'en': 'Private yacht and boat tour',
        'ar': 'جولة خاصة باليخت والقارب',
      }),
      SiteText({
        'tr': 'Vize, resmi evrak ve noter desteği',
        'en': 'Visa, official documents and notary support',
        'ar': 'دعم التأشيرات والوثائق الرسمية والكاتب بالعدل',
      }),
      SiteText({
        'tr': 'Uçak bileti talebi',
        'en': 'Flight ticket assistance',
        'ar': 'طلب تذاكر الطيران',
      }),
      SiteText({
        'tr': 'Midibüs veya büyük otobüs talebi',
        'en': 'Minibus or coach request',
        'ar': 'طلب حافلة صغيرة أو كبيرة',
      }),
      SiteText({
        'tr': 'Lisanslı tur rehberi',
        'en': 'Licensed tour guide',
        'ar': 'مرشد سياحي مرخص',
      }),
      SiteText({
        'tr': 'Emlak portföyü görmek istiyorum',
        'en': 'I would like to view properties',
        'ar': 'أرغب في مشاهدة العقارات',
      }),
      SiteText({
        'tr': '10+ kişi grup veya kurumsal rezervasyon',
        'en': 'Group or corporate booking for 10+ guests',
        'ar': 'حجز لمجموعة أو شركة لأكثر من 10 أشخاص',
      }),
    ],
    fleet: [
      SiteContentItem(
        title: SiteText({'tr': 'Mercedes-Benz Vito Maybach Edition VIP'}),
        description: SiteText({
          'tr': '6+1 kişi • 6 büyük valiz • otomatik',
          'en': '6+1 guests • 6 large bags • automatic',
        }),
        features: [
          SiteText({
            'tr': 'Yıldız tavan aydınlatması',
            'en': 'Starry ceiling lights',
            'ar': 'إضاءة سقف مرصعة بالنجوم',
          }),
          SiteText({
            'tr': '32" Smart TV ve Apple TV',
            'en': '32-inch Smart TV and Apple TV',
            'ar': 'تلفاز ذكي 32 بوصة وApple TV',
          }),
          SiteText({
            'tr': 'Masajlı deri koltuklar',
            'en': 'Massage leather seats',
            'ar': 'مقاعد جلدية مع خاصية التدليك',
          }),
          SiteText({
            'tr': 'Buzdolabı ve Nespresso barı',
            'en': 'Refrigerator and Nespresso bar',
            'ar': 'ثلاجة وركن نسبرسو',
          }),
          SiteText({
            'tr': 'Özel mahremiyet bölmesi',
            'en': 'Private passenger partition',
            'ar': 'حاجز خاص للخصوصية',
          }),
        ],
      ),
      SiteContentItem(
        title: SiteText({'tr': 'Mercedes-Benz V-Class Avantgarde Lounge'}),
        description: SiteText({
          'tr': '7 kişi • 7 büyük valiz • 9G-Tronic otomatik',
          'en': '7 guests • 7 large bags • 9G-Tronic automatic',
        }),
        features: [
          SiteText({
            'tr': 'Burmester çevresel ses sistemi',
            'en': 'Burmester surround sound system',
            'ar': 'نظام صوت محيطي من بورميستر',
          }),
          SiteText({
            'tr': 'Panoramik cam tavan',
            'en': 'Panoramic glass roof',
            'ar': 'سقف زجاجي بانورامي',
          }),
          SiteText({
            'tr': 'Karşılıklı konferans oturma düzeni',
            'en': 'Face-to-face conference seating',
            'ar': 'مقاعد اجتماعات متقابلة',
          }),
          SiteText({
            'tr': 'Kablosuz şarj ve Wi-Fi',
            'en': 'Wireless charging and Wi-Fi',
            'ar': 'شحن لاسلكي وواي فاي',
          }),
          SiteText({
            'tr': 'VIP bagaj hizmeti',
            'en': 'VIP luggage service',
            'ar': 'خدمة أمتعة VIP',
          }),
        ],
      ),
      SiteContentItem(
        title: SiteText({'tr': 'Mercedes-Benz Sprinter Executive VIP Lounge'}),
        description: SiteText({
          'tr': '12–16 kişi • 16+ büyük valiz • otomatik',
          'en': '12–16 guests • 16+ large bags • automatic',
        }),
        features: [
          SiteText({
            'tr': 'Geniş iç hacim ve yüksek tavan',
            'en': 'Spacious interior and high roof',
            'ar': 'مساحة داخلية واسعة وسقف مرتفع',
          }),
          SiteText({
            'tr': 'Çift ekran sinema sistemi',
            'en': 'Dual-screen entertainment system',
            'ar': 'نظام ترفيه بشاشتين',
          }),
          SiteText({
            'tr': 'Özel WC ve lavabo opsiyonu',
            'en': 'Optional private toilet and sink',
            'ar': 'مرحاض ومغسلة خاصة عند الطلب',
          }),
          SiteText({
            'tr': 'Okuma ışıkları ve USB bağlantıları',
            'en': 'Reading lights and USB ports',
            'ar': 'مصابيح قراءة ومنافذ USB',
          }),
          SiteText({
            'tr': 'Geniş bagaj bölümü',
            'en': 'Large luggage compartment',
            'ar': 'مساحة واسعة للأمتعة',
          }),
        ],
      ),
      SiteContentItem(
        title: SiteText({'tr': 'Mercedes-Benz S-Class / Maybach Sedan'}),
        description: SiteText({
          'tr': '3 kişi • 3 valiz • otomatik',
          'en': '3 guests • 3 bags • automatic',
        }),
        features: [
          SiteText({
            'tr': 'First-class arka konsol',
            'en': 'First-class rear console',
            'ar': 'كونسول خلفي من الدرجة الأولى',
          }),
          SiteText({
            'tr': 'Aktif gürültü engelleme',
            'en': 'Active noise cancellation',
            'ar': 'إلغاء نشط للضوضاء',
          }),
          SiteText({
            'tr': 'Chauffeur paketi ve yatar koltuk',
            'en': 'Chauffeur package and reclining seat',
            'ar': 'باقة سائق خاص ومقعد قابل للإمالة',
          }),
          SiteText({
            'tr': 'Şampanya soğutucu',
            'en': 'Champagne cooler',
            'ar': 'مبرد شمبانيا',
          }),
          SiteText({
            'tr': 'Özel koruma ve protokol sürüşü',
            'en': 'Close protection and protocol driving',
            'ar': 'حماية خاصة وقيادة بروتوكولية',
          }),
        ],
      ),
      SiteContentItem(
        title: SiteText({'tr': 'VW Caravelle Exclusive VIP'}),
        description: SiteText({
          'tr': 'VIP kabin • şoförlü şehirlerarası ulaşım',
          'en': 'VIP cabin • chauffeur-driven intercity travel',
        }),
      ),
      SiteContentItem(
        title: SiteText({'tr': 'Toyota Corolla Hybrid'}),
        description: SiteText({
          'tr': 'Sedan • otomatik • 5 kişi',
          'en': 'Sedan • automatic • 5 guests',
        }),
      ),
      SiteContentItem(
        title: SiteText({'tr': 'Peugeot 3008 Allure SUV'}),
        description: SiteText({
          'tr': 'SUV • otomatik • 5 kişi',
          'en': 'SUV • automatic • 5 guests',
        }),
      ),
      SiteContentItem(
        title: SiteText({'tr': 'Dacia Duster 4x4'}),
        description: SiteText({
          'tr': 'Yayla yollarına uygun 4x4 • 5 kişi',
          'en': '4x4 for mountain routes • 5 guests',
        }),
      ),
      SiteContentItem(
        title: SiteText({'tr': 'Renault Megane Sedan'}),
        description: SiteText({
          'tr': 'Dizel otomatik • 5 kişi',
          'en': 'Diesel automatic • 5 guests',
        }),
      ),
      SiteContentItem(
        title: SiteText({'tr': 'Fiat Egea Cross'}),
        description: SiteText({
          'tr': 'Otomatik crossover • 5 kişi',
          'en': 'Automatic crossover • 5 guests',
        }),
      ),
      SiteContentItem(
        title: SiteText({'tr': 'Volkswagen Passat / Arteon'}),
        description: SiteText({
          'tr': 'Executive • otomatik • 5 kişi',
          'en': 'Executive • automatic • 5 guests',
        }),
      ),
    ],
    properties: [
      SiteContentItem(
        title: SiteText({
          'tr': 'Trabzon Akçaabat deniz manzaralı lüks villa',
          'en': 'Sea-view luxury villa in Akçaabat, Trabzon',
        }),
        description: SiteText({
          'tr': '6+2 • 550 m² • sonsuzluk havuzu • akıllı ev • geniş bahçe',
          'en': '6+2 • 550 m² • infinity pool • smart home • spacious garden',
        }),
        location: SiteText({
          'tr': 'Trabzon, Akçaabat / Söğütlü',
          'en': 'Söğütlü, Akçaabat, Trabzon',
          'ar': 'سوغوتلو، أكشابات، طرابزون',
        }),
        price: SiteText({
          'tr': r'$680,000 / Satılık',
          'en': r'$680,000 / For sale',
        }),
        badge: SiteText({
          'tr': 'Vatandaşlığa uygun',
          'en': 'Citizenship eligible',
        }),
      ),
      SiteContentItem(
        title: SiteText({
          'tr': 'Rize Çamlıhemşin nehir kenarı ahşap dağ evi',
          'en': 'Riverside wooden lodge in Çamlıhemşin, Rize',
        }),
        description: SiteText({
          'tr':
              '3+1 • 210 m² • şömine • jakuzi • nehir manzarası • yüksek kira '
              'getirisi',
          'en':
              '3+1 • 210 m² • fireplace • jacuzzi • river view • strong rental '
              'potential',
        }),
        location: SiteText({
          'tr': 'Rize, Çamlıhemşin / Fırtına Vadisi',
          'en': 'Fırtına Valley, Çamlıhemşin, Rize',
          'ar': 'وادي فيرتينا، جامليهمشين، ريزه',
        }),
        price: SiteText({
          'tr': r'$390,000 / Satılık',
          'en': r'$390,000 / For sale',
        }),
        badge: SiteText({
          'tr': 'Yüksek turizm getirisi',
          'en': 'High tourism potential',
        }),
      ),
      SiteContentItem(
        title: SiteText({
          'tr': 'Trabzon Yalıncak ultra lüks rezidans daireleri',
          'en': 'Ultra-luxury residences in Yalıncak, Trabzon',
        }),
        description: SiteText({
          'tr': '4+1 • 230 m² • güvenlik • kapalı otopark • fitness ve SPA',
          'en': '4+1 • 230 m² • security • indoor parking • fitness and spa',
        }),
        location: SiteText({
          'tr': 'Trabzon, Yalıncak (Havalimanına 5 dk)',
          'en': 'Yalıncak, Trabzon (5 minutes from the airport)',
          'ar': 'يالينجاك، طرابزون (5 دقائق من المطار)',
        }),
        price: SiteText({
          'tr': r'$285,000 / Satılık',
          'en': r'$285,000 / For sale',
        }),
        badge: SiteText({
          'tr': 'Havalimanı ve sahil yanı',
          'en': 'Near airport and coast',
        }),
      ),
    ],
    destinations: [
      SiteContentItem(
        title: SiteText({
          'tr': 'Trabzon ve Karadeniz',
          'en': 'Trabzon & Black Sea',
        }),
        description: SiteText({
          'tr':
              'Sümela Manastırı, Uzungöl, Sera Gölü ve Boztepe manzarasıyla '
              'Karadeniz’in kalbi.',
          'en':
              'The heart of the Black Sea, with Sumela Monastery, Uzungöl, '
              'Sera Lake and Boztepe.',
        }),
        features: [
          SiteText({
            'tr': 'Uzungöl',
            'en': 'Uzungöl Lake',
            'ar': 'بحيرة أوزونغول',
          }),
          SiteText({
            'tr': 'Sümela Manastırı',
            'en': 'Sumela Monastery',
            'ar': 'دير سوميلا',
          }),
          SiteText({
            'tr': 'Hıdırnebi Yaylası',
            'en': 'Hıdırnebi Plateau',
            'ar': 'هضبة هيديرنيبي',
          }),
          SiteText({
            'tr': 'Sera Gölü',
            'en': 'Sera Lake',
            'ar': 'بحيرة سيرا',
          }),
        ],
      ),
      SiteContentItem(
        title: SiteText({
          'tr': 'Rize ve Ayder Yaylaları',
          'en': 'Rize & Ayder',
        }),
        description: SiteText({
          'tr': 'Pokut Yaylası, Fırtına Deresi, tarihi Zilkale ve kaplıcalar.',
          'en':
              'Pokut Plateau, Fırtına Valley, historic Zilkale and hot '
              'springs.',
        }),
        features: [
          SiteText({
            'tr': 'Ayder Yaylası',
            'en': 'Ayder Plateau',
            'ar': 'هضبة آيدر',
          }),
          SiteText({
            'tr': 'Zilkale',
            'en': 'Zilkale Castle',
            'ar': 'قلعة زيل',
          }),
          SiteText({
            'tr': 'Fırtına Vadisi',
            'en': 'Fırtına Valley',
            'ar': 'وادي فيرتينا',
          }),
          SiteText({
            'tr': 'Palovit Şelalesi',
            'en': 'Palovit Waterfall',
            'ar': 'شلال بالوفيت',
          }),
        ],
      ),
      SiteContentItem(
        title: SiteText({
          'tr': 'Batum ve Gürcistan Sahili',
          'en': 'Batumi & Georgia',
        }),
        description: SiteText({
          'tr':
              'Trabzon ve Rize’den günübirlik veya konaklamalı sahil ve şehir '
              'gezileri.',
          'en':
              'Day trips or overnight coastal and city tours from Trabzon '
              'and Rize.',
        }),
        features: [
          SiteText({
            'tr': 'Batum Bulvarı',
            'en': 'Batumi Boulevard',
            'ar': 'جادة باتومي',
          }),
          SiteText({
            'tr': 'Ali & Nino Heykeli',
            'en': 'Ali and Nino Statue',
            'ar': 'تمثال علي ونينو',
          }),
          SiteText({
            'tr': 'Botanik Bahçesi',
            'en': 'Botanical Garden',
            'ar': 'الحديقة النباتية',
          }),
          SiteText({
            'tr': 'Piazza Meydanı',
            'en': 'Piazza Square',
            'ar': 'ساحة بيازا',
          }),
        ],
      ),
      SiteContentItem(
        title: SiteText({
          'tr': 'İstanbul ve Boğaziçi',
          'en': 'Istanbul & Bosphorus',
        }),
        description: SiteText({
          'tr':
              'Ayasofya, Topkapı Sarayı, özel yat turu ve seçkin alışveriş '
              'noktaları.',
          'en':
              'Hagia Sophia, Topkapı Palace, private yacht tours and premium '
              'shopping.',
        }),
        features: [
          SiteText({
            'tr': 'Ayasofya & Sultanahmet',
            'en': 'Hagia Sophia and Sultanahmet',
            'ar': 'آيا صوفيا والسلطان أحمد',
          }),
          SiteText({
            'tr': 'Boğazda VIP yat turu',
            'en': 'VIP yacht tour on the Bosphorus',
            'ar': 'جولة يخت VIP في البوسفور',
          }),
          SiteText({
            'tr': 'Topkapı Sarayı',
            'en': 'Topkapı Palace',
            'ar': 'قصر توبكابي',
          }),
          SiteText({
            'tr': 'Kapalıçarşı',
            'en': 'Grand Bazaar',
            'ar': 'البازار الكبير',
          }),
        ],
      ),
    ],
    packages: [
      SiteContentItem(
        title: SiteText({
          'tr': 'Karadeniz ve Yaylalar',
          'en': 'Black Sea & Highlands',
        }),
        description: SiteText({
          'tr': 'Trabzon + Rize • 5 gün',
          'en': 'Trabzon + Rize • 5 days',
        }),
      ),
      SiteContentItem(
        title: SiteText({
          'tr': 'Karadeniz ve Batum',
          'en': 'Black Sea & Batumi',
        }),
        description: SiteText({
          'tr': 'Trabzon + Batum • 7 gün',
          'en': 'Trabzon + Batumi • 7 days',
        }),
      ),
      SiteContentItem(
        title: SiteText({
          'tr': 'İstanbul ve Boğaziçi',
          'en': 'Istanbul & Bosphorus',
        }),
        description: SiteText({
          'tr': 'Tarih + yat turu • 4 gün',
          'en': 'History + yacht tour • 4 days',
        }),
      ),
      SiteContentItem(
        title: SiteText({
          'tr': 'VIP Villa ve Emlak Turu',
          'en': 'VIP Villa & Property Tour',
        }),
        description: SiteText({
          'tr': 'Yatırım + tatil • 4 gün',
          'en': 'Investment + holiday • 4 days',
        }),
      ),
    ],
  );

  Map<String, dynamic> toJson() => {
    'brand': brand.toJson(),
    'headline': headline.toJson(),
    'introduction': introduction.toJson(),
    'phone': phone,
    'email': email,
    'address': address,
    'license': license.toJson(),
    'services': services.map((item) => item.toJson()).toList(),
    'fleet': fleet.map((item) => item.toJson()).toList(),
    'properties': properties.map((item) => item.toJson()).toList(),
    'destinations': destinations.map((item) => item.toJson()).toList(),
    'packages': packages.map((item) => item.toJson()).toList(),
    'booking_options': bookingOptions.map((option) => option.toJson()).toList(),
  };

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('"$key" must be a non-empty string.');
    }
    return value.trim();
  }

  static List<SiteContentItem> _items(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! List) {
      throw FormatException('"$key" must be a list.');
    }
    return value.map((item) {
      if (item is! Map<String, dynamic>) {
        throw FormatException('Every "$key" item must be an object.');
      }
      return SiteContentItem.fromJson(item);
    }).toList();
  }

  static List<SiteText> _texts(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! List) {
      throw FormatException('"$key" must be a list.');
    }
    return value.map((item) => SiteText.fromJson(item, key)).toList();
  }
}

class SiteContentItem {
  const SiteContentItem({
    required this.title,
    required this.description,
    this.location,
    this.price,
    this.badge,
    this.features = const [],
  });

  factory SiteContentItem.fromJson(Map<String, dynamic> json) {
    final features = json['features'];
    if (features != null && features is! List) {
      throw const FormatException('"features" must be a list.');
    }
    return SiteContentItem(
      title: SiteText.fromJson(json['title'], 'title'),
      description: SiteText.fromJson(json['description'], 'description'),
      location: json['location'] == null
          ? null
          : SiteText.fromJson(json['location'], 'location'),
      price: json['price'] == null
          ? null
          : SiteText.fromJson(json['price'], 'price'),
      badge: json['badge'] == null
          ? null
          : SiteText.fromJson(json['badge'], 'badge'),
      features: (features as List<dynamic>? ?? const [])
          .map((item) => SiteText.fromJson(item, 'feature'))
          .toList(),
    );
  }

  final SiteText title;
  final SiteText description;
  final SiteText? location;
  final SiteText? price;
  final SiteText? badge;
  final List<SiteText> features;

  Map<String, dynamic> toJson() => {
    'title': title.toJson(),
    'description': description.toJson(),
    if (location != null) 'location': location!.toJson(),
    if (price != null) 'price': price!.toJson(),
    if (badge != null) 'badge': badge!.toJson(),
    if (features.isNotEmpty)
      'features': features.map((feature) => feature.toJson()).toList(),
  };
}

class SiteText {
  const SiteText(this.translations);

  factory SiteText.fromJson(dynamic value, String field) {
    if (value is String && value.trim().isNotEmpty) {
      return SiteText({'tr': value.trim(), 'en': value.trim()});
    }
    if (value is Map<String, dynamic>) {
      final translations = <String, String>{};
      for (final entry in value.entries) {
        if (entry.value is String &&
            (entry.value as String).trim().isNotEmpty) {
          translations[entry.key] = (entry.value as String).trim();
        }
      }
      if (translations.isNotEmpty) return SiteText(translations);
    }
    throw FormatException('"$field" must be a string or translation map.');
  }

  final Map<String, String> translations;

  String text(String locale) =>
      translations[locale] ?? translations['en'] ?? translations.values.first;

  Map<String, String> toJson() => Map<String, String>.of(translations);
}
