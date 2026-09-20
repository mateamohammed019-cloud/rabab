/// ملفات الموسيقى الخاصة بالهدية.
///
/// ضع ملفات mp3 داخل المجلد [assets/audio] ثم أضفها هنا
/// بالترتيب الذي تريده في القائمة.
///
/// مثال: ملف اسمه `assets/audio/romantic.mp3` يُكتب هكذا:
///   Song(title: 'اسم الأغنية', file: 'assets/audio/romantic.mp3'),
class Song {
  const Song({required this.title, required this.file});

  final String title;
  final String file;
}

const List<Song> songs = [
  Song(title: 'المجانين — علي ديك وليال عبود', file: 'assets/audio/song_01.mp3'),
  Song(title: 'خليك معايا — عمرو دياب', file: 'assets/audio/song_02.mp3'),
  Song(title: 'قصاد عيني — عمرو دياب', file: 'assets/audio/song_03.mp3'),
  Song(title: 'تسونامي — شوقي', file: 'assets/audio/song_04.mp3'),
  Song(title: 'كي نبحجيها — شب عقيل وشيرين', file: 'assets/audio/song_05.mp3'),
  Song(title: 'أحلى رسمة — فضل شاكر', file: 'assets/audio/song_06.mp3'),
  Song(title: 'معقول — فضل شاكر', file: 'assets/audio/song_07.mp3'),
  Song(title: 'تعا يا حبيبي — جاد خليفة', file: 'assets/audio/song_08.mp3'),
  Song(title: 'الحب كاين — مراد مجود ورشيد قاسمي', file: 'assets/audio/song_09.mp3'),
  Song(title: 'على شانك — نانسي عجرم', file: 'assets/audio/song_10.mp3'),
  Song(title: 'يا قلبي — نانسي عجرم', file: 'assets/audio/song_11.mp3'),
  Song(title: 'طبعًا طبعًا — شيرين', file: 'assets/audio/song_12.mp3'),
  Song(title: 'حبك رزق — تامر عاشور', file: 'assets/audio/song_13.mp3'),
  Song(title: 'قسم الشكاوي — تولوت', file: 'assets/audio/song_14.mp3'),
  Song(title: 'نعم أنت — محمد السالم', file: 'assets/audio/song_15.mp3'),
];