import 'package:flutter/material.dart';

class Dua {
  const Dua({
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.source,
  });

  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String source;
}

class DuaCategory {
  const DuaCategory({
    required this.name,
    required this.icon,
    required this.duas,
  });

  final String name;
  final IconData icon;
  final List<Dua> duas;
}

const List<DuaCategory> duaCategories = [
  DuaCategory(
    name: 'Morning & Evening',
    icon: Icons.wb_twilight,
    duas: [
      Dua(
        title: 'Upon entering the morning',
        arabic:
            'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        transliteration:
            "Asbahna wa asbahal-mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la shareeka lah, lahul-mulku wa lahul-hamd, wa huwa 'ala kulli shay'in qadeer.",
        translation:
            'We have entered the morning and the dominion belongs to Allah. Praise is to Allah. There is no deity but Allah alone, with no partner. To Him belongs the dominion and the praise, and He is able to do all things.',
        source: 'Muslim',
      ),
      Dua(
        title: 'Upon entering the evening',
        arabic:
            'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        transliteration:
            "Amsayna wa amsal-mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la shareeka lah, lahul-mulku wa lahul-hamd, wa huwa 'ala kulli shay'in qadeer.",
        translation:
            'We have entered the evening and the dominion belongs to Allah. Praise is to Allah. There is no deity but Allah alone, with no partner. To Him belongs the dominion and the praise, and He is able to do all things.',
        source: 'Muslim',
      ),
      Dua(
        title: 'Sayyidul Istighfar (master of seeking forgiveness)',
        arabic:
            'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
        transliteration:
            "Allahumma anta rabbee la ilaha illa ant, khalaqtanee wa ana 'abduk, wa ana 'ala 'ahdika wa wa'dika mas-tata't, a'oodhu bika min sharri ma sana't, aboo'u laka bini'matika 'alayy, wa aboo'u bidhanbee faghfir lee fa'innahu la yaghfirudh-dhunooba illa ant.",
        translation:
            'O Allah, You are my Lord; there is no deity but You. You created me and I am Your servant, and I abide by Your covenant and promise as best I can. I seek refuge in You from the evil of what I have done. I acknowledge Your favour upon me and I acknowledge my sin, so forgive me, for none forgives sins but You.',
        source: 'Al-Bukhari',
      ),
      Dua(
        title: 'Protection in the morning and evening (3 times)',
        arabic:
            'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
        transliteration:
            "Bismillahil-ladhee la yadurru ma'as-mihi shay'un fil-ardi wa la fis-sama', wa huwas-samee'ul-'aleem.",
        translation:
            'In the name of Allah, with whose name nothing on earth or in heaven can cause harm, and He is the All-Hearing, the All-Knowing.',
        source: 'Abu Dawud, At-Tirmidhi',
      ),
    ],
  ),
  DuaCategory(
    name: 'Sleep & Waking',
    icon: Icons.bedtime,
    duas: [
      Dua(
        title: 'Before sleeping',
        arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
        transliteration: 'Bismika Allahumma amootu wa ahya.',
        translation: 'In Your name, O Allah, I die and I live.',
        source: 'Al-Bukhari',
      ),
      Dua(
        title: 'Upon waking up',
        arabic:
            'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
        transliteration:
            "Alhamdu lillahil-ladhee ahyana ba'da ma amatana wa ilayhin-nushoor.",
        translation:
            'Praise is to Allah who gave us life after having taken it from us, and to Him is the resurrection.',
        source: 'Al-Bukhari',
      ),
    ],
  ),
  DuaCategory(
    name: 'Food & Drink',
    icon: Icons.restaurant,
    duas: [
      Dua(
        title: 'Before eating',
        arabic: 'بِسْمِ اللَّهِ',
        transliteration: 'Bismillah.',
        translation:
            'In the name of Allah. (If you forget at the start, say: Bismillahi fee awwalihi wa akhirihi — In the name of Allah at its beginning and at its end.)',
        source: 'Abu Dawud, At-Tirmidhi',
      ),
      Dua(
        title: 'After eating',
        arabic:
            'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
        transliteration:
            "Alhamdu lillahil-ladhee at'amanee hadha wa razaqaneehi min ghayri hawlin minnee wa la quwwah.",
        translation:
            'Praise is to Allah who has fed me this and provided it for me without any might or power on my part.',
        source: 'Abu Dawud, At-Tirmidhi, Ibn Majah',
      ),
    ],
  ),
  DuaCategory(
    name: 'Home & Travel',
    icon: Icons.home,
    duas: [
      Dua(
        title: 'Leaving the home',
        arabic:
            'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
        transliteration:
            "Bismillah, tawakkaltu 'alallah, wa la hawla wa la quwwata illa billah.",
        translation:
            'In the name of Allah, I place my trust in Allah, and there is no might nor power except with Allah.',
        source: 'Abu Dawud, At-Tirmidhi',
      ),
      Dua(
        title: 'Entering the home',
        arabic:
            'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى رَبِّنَا تَوَكَّلْنَا',
        transliteration:
            "Bismillahi walajna, wa bismillahi kharajna, wa 'ala rabbina tawakkalna.",
        translation:
            'In the name of Allah we enter, and in the name of Allah we leave, and upon our Lord we place our trust.',
        source: 'Abu Dawud',
      ),
      Dua(
        title: 'Travel (riding a vehicle)',
        arabic:
            'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
        transliteration:
            'Subhanal-ladhee sakhkhara lana hadha wa ma kunna lahu muqrineen, wa inna ila rabbina lamunqaliboon.',
        translation:
            'Glory to Him who has subjected this to us, and we could never have it by our own efforts. Surely, to our Lord we are returning.',
        source: "Quran 43:13-14; Muslim",
      ),
    ],
  ),
  DuaCategory(
    name: 'Salah & Mosque',
    icon: Icons.mosque,
    duas: [
      Dua(
        title: 'After completing wudu',
        arabic:
            'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
        transliteration:
            "Ash-hadu an la ilaha illallahu wahdahu la shareeka lah, wa ash-hadu anna Muhammadan 'abduhu wa rasooluh.",
        translation:
            'I bear witness that there is no deity but Allah alone, with no partner, and I bear witness that Muhammad is His servant and Messenger.',
        source: 'Muslim',
      ),
      Dua(
        title: 'After hearing the athan',
        arabic:
            'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ الْقَائِمَةِ، آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ',
        transliteration:
            "Allahumma rabba hadhihid-da'watit-tammah, was-salatil-qa'imah, ati Muhammadanil-waseelata wal-fadeelah, wab'ath-hu maqamam-mahmoodanil-ladhee wa'adtah.",
        translation:
            'O Allah, Lord of this perfect call and the established prayer, grant Muhammad the intercession and favour, and raise him to the praised station You have promised him.',
        source: 'Al-Bukhari',
      ),
      Dua(
        title: 'Entering the mosque',
        arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
        transliteration: 'Allahummaf-tah lee abwaba rahmatik.',
        translation: 'O Allah, open the gates of Your mercy for me.',
        source: 'Muslim',
      ),
      Dua(
        title: 'Leaving the mosque',
        arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
        transliteration: "Allahumma innee as'aluka min fadlik.",
        translation: 'O Allah, I ask You of Your bounty.',
        source: 'Muslim',
      ),
    ],
  ),
  DuaCategory(
    name: 'Forgiveness & Distress',
    icon: Icons.favorite,
    duas: [
      Dua(
        title: 'In times of distress',
        arabic:
            'لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ السَّمَوَاتِ وَرَبُّ الْأَرْضِ وَرَبُّ الْعَرْشِ الْكَرِيمِ',
        transliteration:
            "La ilaha illallahul-'azeemul-haleem, la ilaha illallahu rabbul-'arshil-'azeem, la ilaha illallahu rabbus-samawati wa rabbul-ardi wa rabbul-'arshil-kareem.",
        translation:
            'There is no deity but Allah, the Mighty, the Forbearing. There is no deity but Allah, Lord of the Magnificent Throne. There is no deity but Allah, Lord of the heavens, Lord of the earth and Lord of the Noble Throne.',
        source: 'Al-Bukhari, Muslim',
      ),
      Dua(
        title: 'Against anxiety and sorrow',
        arabic:
            'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
        transliteration:
            "Allahumma innee a'oodhu bika minal-hammi wal-hazan, wal-'ajzi wal-kasal, wal-bukhli wal-jubn, wa dala'id-dayni wa ghalabatir-rijal.",
        translation:
            'O Allah, I seek refuge in You from worry and grief, from incapacity and laziness, from miserliness and cowardice, from the burden of debt and from being overpowered by men.',
        source: 'Al-Bukhari',
      ),
      Dua(
        title: 'Good in this world and the next',
        arabic:
            'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
        transliteration:
            "Rabbana atina fid-dunya hasanah, wa fil-akhirati hasanah, wa qina 'adhaban-nar.",
        translation:
            'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
        source: 'Quran 2:201',
      ),
      Dua(
        title: 'For parents and the believers',
        arabic:
            'رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
        transliteration:
            'Rabbanagh-fir lee wa liwalidayya wa lil-mu’mineena yawma yaqoomul-hisab.',
        translation:
            'Our Lord, forgive me and my parents and the believers on the Day the account is established.',
        source: 'Quran 14:41',
      ),
      Dua(
        title: 'For increase in knowledge',
        arabic: 'رَبِّ زِدْنِي عِلْمًا',
        transliteration: "Rabbi zidnee 'ilma.",
        translation: 'My Lord, increase me in knowledge.',
        source: 'Quran 20:114',
      ),
    ],
  ),
];
