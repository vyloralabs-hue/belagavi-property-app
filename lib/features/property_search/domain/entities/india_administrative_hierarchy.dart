import 'package:equatable/equatable.dart';

/// Administrative unit type in the Indian hierarchy
enum AdministrativeLevel {
  country,
  state,
  unionTerritory,
  district,
  talukTehsil,
  cityTown,
  village,
  locality,
}

/// Represents a state or union territory of India
class IndiaState extends Equatable {
  final String code; // e.g. 'KA', 'MH', 'DL'
  final String name; // e.g. 'Karnataka', 'Maharashtra'
  final bool isUnionTerritory;
  final String capital;
  final List<String> aliases;

  const IndiaState({
    required this.code,
    required this.name,
    this.isUnionTerritory = false,
    required this.capital,
    this.aliases = const [],
  });

  @override
  List<Object?> get props => [code, name, isUnionTerritory, capital, aliases];
}

/// Represents a district in India with taluks/tehsils and major cities
class IndiaDistrict extends Equatable {
  final String name;
  final String stateCode;
  final String stateName;
  final List<String> taluks;
  final List<String> majorCities;
  final List<String> aliases;

  const IndiaDistrict({
    required this.name,
    required this.stateCode,
    required this.stateName,
    this.taluks = const [],
    this.majorCities = const [],
    this.aliases = const [],
  });

  @override
  List<Object?> get props => [name, stateCode, stateName, taluks, majorCities, aliases];
}

/// Complete Registry of 28 States, 8 UTs, District and Taluk hierarchy
class IndiaAdministrativeHierarchy {
  IndiaAdministrativeHierarchy._();

  /// 28 States of the Republic of India
  static const List<IndiaState> states = [
    IndiaState(code: 'AP', name: 'Andhra Pradesh', capital: 'Amaravati', aliases: ['ap']),
    IndiaState(code: 'AR', name: 'Arunachal Pradesh', capital: 'Itanagar', aliases: ['ar']),
    IndiaState(code: 'AS', name: 'Assam', capital: 'Dispur', aliases: ['as']),
    IndiaState(code: 'BR', name: 'Bihar', capital: 'Patna', aliases: ['br']),
    IndiaState(code: 'CG', name: 'Chhattisgarh', capital: 'Raipur', aliases: ['cg', 'chhattisgarh']),
    IndiaState(code: 'GA', name: 'Goa', capital: 'Panaji', aliases: ['ga']),
    IndiaState(code: 'GJ', name: 'Gujarat', capital: 'Gandhinagar', aliases: ['gj']),
    IndiaState(code: 'HR', name: 'Haryana', capital: 'Chandigarh', aliases: ['hr']),
    IndiaState(code: 'HP', name: 'Himachal Pradesh', capital: 'Shimla', aliases: ['hp']),
    IndiaState(code: 'JH', name: 'Jharkhand', capital: 'Ranchi', aliases: ['jh']),
    IndiaState(code: 'KA', name: 'Karnataka', capital: 'Bengaluru', aliases: ['ka', 'kar']),
    IndiaState(code: 'KL', name: 'Kerala', capital: 'Thiruvananthapuram', aliases: ['kl', 'ker']),
    IndiaState(code: 'MP', name: 'Madhya Pradesh', capital: 'Bhopal', aliases: ['mp']),
    IndiaState(code: 'MH', name: 'Maharashtra', capital: 'Mumbai', aliases: ['mh', 'mah']),
    IndiaState(code: 'MN', name: 'Manipur', capital: 'Imphal', aliases: ['mn']),
    IndiaState(code: 'ML', name: 'Meghalaya', capital: 'Shillong', aliases: ['ml']),
    IndiaState(code: 'MZ', name: 'Mizoram', capital: 'Aizawl', aliases: ['mz']),
    IndiaState(code: 'NL', name: 'Nagaland', capital: 'Kohima', aliases: ['nl']),
    IndiaState(code: 'OD', name: 'Odisha', capital: 'Bhubaneswar', aliases: ['od', 'orissa']),
    IndiaState(code: 'PB', name: 'Punjab', capital: 'Chandigarh', aliases: ['pb']),
    IndiaState(code: 'RJ', name: 'Rajasthan', capital: 'Jaipur', aliases: ['rj']),
    IndiaState(code: 'SK', name: 'Sikkim', capital: 'Gangtok', aliases: ['sk']),
    IndiaState(code: 'TN', name: 'Tamil Nadu', capital: 'Chennai', aliases: ['tn']),
    IndiaState(code: 'TS', name: 'Telangana', capital: 'Hyderabad', aliases: ['ts', 'tg']),
    IndiaState(code: 'TR', name: 'Tripura', capital: 'Agartala', aliases: ['tr']),
    IndiaState(code: 'UP', name: 'Uttar Pradesh', capital: 'Lucknow', aliases: ['up']),
    IndiaState(code: 'UK', name: 'Uttarakhand', capital: 'Dehradun', aliases: ['uk', 'ua', 'uttaranchal']),
    IndiaState(code: 'WB', name: 'West Bengal', capital: 'Kolkata', aliases: ['wb', 'bengal']),
  ];

  /// 8 Union Territories
  static const List<IndiaState> unionTerritories = [
    IndiaState(code: 'AN', name: 'Andaman and Nicobar Islands', capital: 'Port Blair', isUnionTerritory: true),
    IndiaState(code: 'CH', name: 'Chandigarh', capital: 'Chandigarh', isUnionTerritory: true),
    IndiaState(code: 'DH', name: 'Dadra and Nagar Haveli and Daman and Diu', capital: 'Daman', isUnionTerritory: true),
    IndiaState(code: 'DL', name: 'Delhi', capital: 'New Delhi', isUnionTerritory: true, aliases: ['dl', 'ncr', 'new delhi']),
    IndiaState(code: 'JK', name: 'Jammu and Kashmir', capital: 'Srinagar / Jammu', isUnionTerritory: true, aliases: ['jk', 'j&k']),
    IndiaState(code: 'LA', name: 'Ladakh', capital: 'Leh', isUnionTerritory: true),
    IndiaState(code: 'LD', name: 'Lakshadweep', capital: 'Kavaratti', isUnionTerritory: true),
    IndiaState(code: 'PY', name: 'Puducherry', capital: 'Puducherry', isUnionTerritory: true, aliases: ['pondicherry']),
  ];

  /// All 36 First-order Subdivisions
  static List<IndiaState> get allStatesAndUTs => [...states, ...unionTerritories];

  /// Comprehensive Districts Registry with primary focus on Karnataka (all 31),
  /// Maharashtra (key border & metros), and national gateway hubs.
  static const List<IndiaDistrict> districts = [
    // ── KARNATAKA (All 31 Districts) ──
    IndiaDistrict(
      name: 'Belagavi',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['belgaum', 'bgm', 'belagaon'],
      majorCities: ['Belagavi', 'Gokak', 'Chikkodi', 'Nippani', 'Bailhongal', 'Athani', 'Sankeshwar', 'Khanapur'],
      taluks: [
        'Belagavi',
        'Gokak',
        'Chikkodi',
        'Bailhongal',
        'Athani',
        'Savadatti',
        'Ramdurg',
        'Hukkeri',
        'Khanapur',
        'Raybag',
        'Kagawad',
        'Kittur',
        'Mudalgi',
        'Nippani',
        'Yaragatti',
      ],
    ),
    IndiaDistrict(
      name: 'Bengaluru Urban',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['bangalore', 'bengaluru', 'blr'],
      majorCities: ['Bengaluru', 'Yelahanka', 'Kengeri', 'Electronic City', 'Whitefield'],
      taluks: ['Bengaluru North', 'Bengaluru South', 'Bengaluru East', 'Anekal', 'Yelahanka'],
    ),
    IndiaDistrict(
      name: 'Bengaluru Rural',
      stateCode: 'KA',
      stateName: 'Karnataka',
      majorCities: ['Doddaballapura', 'Devanahalli', 'Hosakote', 'Nelamangala'],
      taluks: ['Devanahalli', 'Doddaballapura', 'Hosakote', 'Nelamangala'],
    ),
    IndiaDistrict(
      name: 'Dharwad',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['hubli', 'hubballi', 'dharwar'],
      majorCities: ['Hubballi', 'Dharwad', 'Navalgund', 'Kalghatgi', 'Kundgol'],
      taluks: ['Dharwad', 'Hubballi Urban', 'Hubballi Rural', 'Kundgol', 'Navalgund', 'Kalghatgi', 'Alnavar'],
    ),
    IndiaDistrict(
      name: 'Mysuru',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['mysore'],
      majorCities: ['Mysuru', 'Nanjangud', 'Hunsur', 'T. Narasipura'],
      taluks: ['Mysuru', 'Nanjangud', 'Hunsur', 'Piriyapatna', 'T. Narasipura', 'K.R. Nagar', 'Saragur'],
    ),
    IndiaDistrict(
      name: 'Bagalkote',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['bagalkot'],
      majorCities: ['Bagalkote', 'Jamkhandi', 'Mudhol', 'Badami', 'Ilkal'],
      taluks: ['Bagalkote', 'Badami', 'Jamkhandi', 'Mudhol', 'Hunagund', 'Bilagi', 'Guledgudda', 'Rabkavi Banhatti', 'Ilkal'],
    ),
    IndiaDistrict(
      name: 'Vijayapura',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['bijapur'],
      majorCities: ['Vijayapura', 'Indi', 'Muddebihal', 'Sindgi', 'Basavana Bagewadi'],
      taluks: ['Vijayapura', 'Indi', 'Basavana Bagewadi', 'Sindgi', 'Muddebihal', 'Talikoti', 'Chadchan', 'Tikota', 'Babaleshwar', 'Kolhar', 'Nidagundi', 'Devar Hippargi'],
    ),
    IndiaDistrict(
      name: 'Uttara Kannada',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['karwar', 'north canara'],
      majorCities: ['Karwar', 'Sirsi', 'Dandeli', 'Kumta', 'Bhatkal', 'Honnavar'],
      taluks: ['Karwar', 'Ankola', 'Kumta', 'Honnavar', 'Bhatkal', 'Sirsi', 'Siddapur', 'Yellapur', 'Haliyal', 'Joida', 'Dandeli'],
    ),
    IndiaDistrict(
      name: 'Dakshina Kannada',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['mangalore', 'mangaluru', 'south canara'],
      majorCities: ['Mangaluru', 'Bantwal', 'Puttur', 'Ujire', 'Moodabidri'],
      taluks: ['Mangaluru', 'Bantwal', 'Belthangady', 'Puttur', 'Sullia', 'Moodabidri', 'Kadaba'],
    ),
    IndiaDistrict(
      name: 'Udupi',
      stateCode: 'KA',
      stateName: 'Karnataka',
      majorCities: ['Udupi', 'Manipal', 'Kundapura', 'Karkala'],
      taluks: ['Udupi', 'Kundapura', 'Karkala', 'Brahmavara', 'Byndoor', 'Kaup', 'Hebri'],
    ),
    IndiaDistrict(
      name: 'Ballari',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['bellary'],
      majorCities: ['Ballari', 'Siruguppa', 'Kampli', 'Sandur'],
      taluks: ['Ballari', 'Siruguppa', 'Sandur', 'Kampli', 'Kurugodu'],
    ),
    IndiaDistrict(
      name: 'Vijayanagara',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['hospet', 'hosapete'],
      majorCities: ['Hosapete', 'Hampi', 'Kudligi', 'Harapanahalli'],
      taluks: ['Hosapete', 'Hagaribommanahalli', 'Harapanahalli', 'Hoovina Hadagali', 'Kotturu', 'Kudligi'],
    ),
    IndiaDistrict(
      name: 'Kalaburagi',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['gulbarga'],
      majorCities: ['Kalaburagi', 'Sedam', 'Shahabad', 'Aland'],
      taluks: ['Kalaburagi', 'Aland', 'Afzalpur', 'Jevargi', 'Sedam', 'Chittapur', 'Chincholi', 'Kamalapur', 'Kalagi', 'Shahabad', 'Yedrami'],
    ),
    IndiaDistrict(
      name: 'Shivamogga',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['shimoga'],
      majorCities: ['Shivamogga', 'Bhadravati', 'Sagara', 'Shikaripura', 'Thirthahalli'],
      taluks: ['Shivamogga', 'Bhadravati', 'Sagara', 'Shikaripura', 'Soraba', 'Thirthahalli', 'Hosanagara'],
    ),
    IndiaDistrict(
      name: 'Tumakuru',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['tumkur'],
      majorCities: ['Tumakuru', 'Tiptur', 'Sira', 'Madhugiri', 'Kunigal'],
      taluks: ['Tumakuru', 'Tiptur', 'Sira', 'Chikkanayakanahalli', 'Gubbi', 'Koratagere', 'Kunigal', 'Madhugiri', 'Pavagada', 'Turuvekere'],
    ),
    IndiaDistrict(
      name: 'Hassan',
      stateCode: 'KA',
      stateName: 'Karnataka',
      majorCities: ['Hassan', 'Arsikere', 'Channarayapatna', 'Sakleshpur', 'Belur'],
      taluks: ['Hassan', 'Alur', 'Arkalgud', 'Arsikere', 'Belur', 'Channarayapatna', 'Holenarasipura', 'Sakleshpur'],
    ),
    IndiaDistrict(
      name: 'Mandya',
      stateCode: 'KA',
      stateName: 'Karnataka',
      majorCities: ['Mandya', 'Maddur', 'Malavalli', 'Srirangapatna'],
      taluks: ['Mandya', 'Maddur', 'Malavalli', 'Pandavapura', 'Srirangapatna', 'Krishnarajpet', 'Nagamangala'],
    ),
    IndiaDistrict(
      name: 'Chikkamagaluru',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['chikmagalur'],
      majorCities: ['Chikkamagaluru', 'Kadur', 'Tarikere', 'Mudigere'],
      taluks: ['Chikkamagaluru', 'Kadur', 'Koppa', 'Mudigere', 'Narasimharajapura', 'Sringeri', 'Tarikere', 'Ajjampura'],
    ),
    IndiaDistrict(
      name: 'Davangere',
      stateCode: 'KA',
      stateName: 'Karnataka',
      majorCities: ['Davangere', 'Harihar', 'Channagiri', 'Honnali'],
      taluks: ['Davangere', 'Harihar', 'Channagiri', 'Honnali', 'Jagalur', 'Nyamathi'],
    ),
    IndiaDistrict(
      name: 'Kolar',
      stateCode: 'KA',
      stateName: 'Karnataka',
      majorCities: ['Kolar', 'KGF', 'Bangarapet', 'Malur', 'Mulbagal'],
      taluks: ['Kolar', 'Bangarapet', 'Malur', 'Mulbagal', 'Srinivaspur', 'KGF'],
    ),
    IndiaDistrict(
      name: 'Chikkaballapura',
      stateCode: 'KA',
      stateName: 'Karnataka',
      majorCities: ['Chikkaballapura', 'Chintamani', 'Gowribidanur', 'Sidlaghatta'],
      taluks: ['Chikkaballapura', 'Bagepalli', 'Chintamani', 'Gowribidanur', 'Gudibanda', 'Sidlaghatta'],
    ),
    IndiaDistrict(
      name: 'Chitradurga',
      stateCode: 'KA',
      stateName: 'Karnataka',
      majorCities: ['Chitradurga', 'Challakere', 'Hiriyur', 'Holalkere'],
      taluks: ['Chitradurga', 'Challakere', 'Hiriyur', 'Holalkere', 'Hosadurga', 'Molakalmuru'],
    ),
    IndiaDistrict(
      name: 'Gadag',
      stateCode: 'KA',
      stateName: 'Karnataka',
      majorCities: ['Gadag', 'Betageri', 'Ron', 'Shirhatti', 'Nargund'],
      taluks: ['Gadag', 'Ron', 'Shirhatti', 'Nargund', 'Mundargi', 'Gajendragad', 'Lakshmeshwar'],
    ),
    IndiaDistrict(
      name: 'Haveri',
      stateCode: 'KA',
      stateName: 'Karnataka',
      majorCities: ['Haveri', 'Ranebennur', 'Byadgi', 'Hirekerur'],
      taluks: ['Haveri', 'Ranebennur', 'Byadgi', 'Hangal', 'Hirekerur', 'Savanur', 'Shiggaon', 'Rattihalli'],
    ),
    IndiaDistrict(
      name: 'Koppal',
      stateCode: 'KA',
      stateName: 'Karnataka',
      majorCities: ['Koppal', 'Gangavathi', 'Kushtagi', 'Yelburga'],
      taluks: ['Koppal', 'Gangavathi', 'Kushtagi', 'Yelburga', 'Karatagi', 'Kukanur'],
    ),
    IndiaDistrict(
      name: 'Raichur',
      stateCode: 'KA',
      stateName: 'Karnataka',
      majorCities: ['Raichur', 'Sindhanur', 'Manvi', 'Lingsugur'],
      taluks: ['Raichur', 'Devadurga', 'Lingsugur', 'Manvi', 'Sindhanur', 'Maski', 'Sirwar'],
    ),
    IndiaDistrict(
      name: 'Bidar',
      stateCode: 'KA',
      stateName: 'Karnataka',
      majorCities: ['Bidar', 'Basavakalyan', 'Humnabad', 'Bhalki'],
      taluks: ['Bidar', 'Basavakalyan', 'Bhalki', 'Humnabad', 'Aurad', 'Hulsoor', 'Kamalnagar'],
    ),
    IndiaDistrict(
      name: 'Yadgir',
      stateCode: 'KA',
      stateName: 'Karnataka',
      majorCities: ['Yadgir', 'Shorapur', 'Shahapur'],
      taluks: ['Yadgir', 'Shahapur', 'Shorapur', 'Gurmitkal', 'Hunasagi', 'Wadgera'],
    ),
    IndiaDistrict(
      name: 'Chamarajanagara',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['chamarajanagar'],
      majorCities: ['Chamarajanagara', 'Kollegal', 'Gundlupet'],
      taluks: ['Chamarajanagara', 'Gundlupet', 'Kollegal', 'Yelandur', 'Hanur'],
    ),
    IndiaDistrict(
      name: 'Kodagu',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['coorg'],
      majorCities: ['Madikeri', 'Virajpet', 'Kushalnagar', 'Somwarpet'],
      taluks: ['Madikeri', 'Somwarpet', 'Virajpet', 'Kushalnagar', 'Ponnampet'],
    ),
    IndiaDistrict(
      name: 'Ramanagara',
      stateCode: 'KA',
      stateName: 'Karnataka',
      aliases: ['ramanagar'],
      majorCities: ['Ramanagara', 'Channapatna', 'Kanakapura', 'Magadi'],
      taluks: ['Ramanagara', 'Channapatna', 'Kanakapura', 'Magadi', 'Harohalli'],
    ),

    // ── MAHARASHTRA (Key Border & Major Districts) ──
    IndiaDistrict(
      name: 'Kolhapur',
      stateCode: 'MH',
      stateName: 'Maharashtra',
      majorCities: ['Kolhapur', 'Ichalkaranji', 'Jaysingpur', 'Gadhinglaj', 'Kagal'],
      taluks: ['Karvir', 'Hatkanangle', 'Shirol', 'Kagal', 'Gadhinglaj', 'Chandgad', 'Radhanagari', 'Bhudargad', 'Ajra', 'Panhala', 'Shahuwadi', 'Gaganbawda'],
    ),
    IndiaDistrict(
      name: 'Sangli',
      stateCode: 'MH',
      stateName: 'Maharashtra',
      majorCities: ['Sangli', 'Miraj', 'Islampur', 'Tasgaon', 'Vita'],
      taluks: ['Miraj', 'Tasgaon', 'Khanapur', 'Atpadi', 'Jat', 'Walwa', 'Shirala', 'Kadegaon', 'Palus', 'Kavathe Mahankal'],
    ),
    IndiaDistrict(
      name: 'Pune',
      stateCode: 'MH',
      stateName: 'Maharashtra',
      aliases: ['poona', 'pun'],
      majorCities: ['Pune', 'Pimpri-Chinchwad', 'Baramati', 'Lonavala', 'Daund', 'Shirur'],
      taluks: ['Haveli', 'Pune City', 'Khed', 'Baramati', 'Shirur', 'Maval', 'Ambegaon', 'Daund', 'Indapur', 'Bhor', 'Purandar', 'Junnar', 'Velhe', 'Mulshi'],
    ),
    IndiaDistrict(
      name: 'Mumbai City',
      stateCode: 'MH',
      stateName: 'Maharashtra',
      aliases: ['bombay', 'south mumbai'],
      majorCities: ['Mumbai'],
      taluks: ['Mumbai City'],
    ),
    IndiaDistrict(
      name: 'Mumbai Suburban',
      stateCode: 'MH',
      stateName: 'Maharashtra',
      aliases: ['bombay suburbs', 'mumbai'],
      majorCities: ['Andheri', 'Bandra', 'Borivali', 'Kurla'],
      taluks: ['Andheri', 'Borivali', 'Kurla'],
    ),
    IndiaDistrict(
      name: 'Thane',
      stateCode: 'MH',
      stateName: 'Maharashtra',
      majorCities: ['Thane', 'Kalyan', 'Dombivli', 'Mira-Bhayandar', 'Ulhasnagar', 'Bhiwandi'],
      taluks: ['Thane', 'Kalyan', 'Bhiwandi', 'Murbad', 'Shahapur', 'Ulhasnagar', 'Ambarnath'],
    ),
    IndiaDistrict(
      name: 'Nagpur',
      stateCode: 'MH',
      stateName: 'Maharashtra',
      majorCities: ['Nagpur', 'Kamptee', 'Umred', 'Katol'],
      taluks: ['Nagpur Urban', 'Nagpur Rural', 'Kamptee', 'Hingna', 'Katol', 'Narkhed', 'Savner', 'Kalameshwar', 'Ramtek', 'Parseoni', 'Mouda', 'Umred', 'Kuhi', 'Bhiwapur'],
    ),
    IndiaDistrict(
      name: 'Nashik',
      stateCode: 'MH',
      stateName: 'Maharashtra',
      aliases: ['nasik'],
      majorCities: ['Nashik', 'Malegaon', 'Sinnar', 'Manmad'],
      taluks: ['Nashik', 'Malegaon', 'Sinnar', 'Niphad', 'Igatpuri', 'Yeola', 'Dindori'],
    ),
    IndiaDistrict(
      name: 'Solapur',
      stateCode: 'MH',
      stateName: 'Maharashtra',
      majorCities: ['Solapur', 'Pandharpur', 'Barshi', 'Akkalkot'],
      taluks: ['Solapur North', 'Solapur South', 'Barshi', 'Pandharpur', 'Akkalkot', 'Mohol', 'Mangalwedha'],
    ),
    IndiaDistrict(
      name: 'Satara',
      stateCode: 'MH',
      stateName: 'Maharashtra',
      majorCities: ['Satara', 'Karad', 'Wai', 'Mahabaleshwar', 'Phaltan'],
      taluks: ['Satara', 'Karad', 'Wai', 'Mahabaleshwar', 'Phaltan', 'Koregaon', 'Khatav'],
    ),

    // ── GOA ──
    IndiaDistrict(
      name: 'North Goa',
      stateCode: 'GA',
      stateName: 'Goa',
      majorCities: ['Panaji', 'Mapusa', 'Bicholim', 'Pernem'],
      taluks: ['Tiswadi', 'Bardez', 'Pernem', 'Bicholim', 'Sattari'],
    ),
    IndiaDistrict(
      name: 'South Goa',
      stateCode: 'GA',
      stateName: 'Goa',
      majorCities: ['Margao', 'Vasco da Gama', 'Ponda', 'Curchorem'],
      taluks: ['Salcete', 'Mormugao', 'Ponda', 'Quepem', 'Sanguem', 'Canacona', 'Dharbandora'],
    ),

    // ── NATIONAL GATEWAY HUBS ──
    IndiaDistrict(
      name: 'Hyderabad',
      stateCode: 'TS',
      stateName: 'Telangana',
      aliases: ['hyd', 'cyberabad', 'secunderabad'],
      majorCities: ['Hyderabad', 'Secunderabad', 'Gachibowli', 'Madhapur'],
      taluks: ['Hyderabad', 'Secunderabad', 'Amberpet', 'Asifnagar', 'Bahadurpura', 'Charminar'],
    ),
    IndiaDistrict(
      name: 'Chennai',
      stateCode: 'TN',
      stateName: 'Tamil Nadu',
      aliases: ['madras', 'chn'],
      majorCities: ['Chennai', 'Tambaram', 'Avadi'],
      taluks: ['Egmore', 'Guindy', 'Mylapore', 'Tondiarpet', 'Velachery', 'Ambattur', 'Alandur'],
    ),
    IndiaDistrict(
      name: 'Kolkata',
      stateCode: 'WB',
      stateName: 'West Bengal',
      aliases: ['calcutta', 'ccu'],
      majorCities: ['Kolkata', 'Salt Lake', 'New Town', 'Howrah'],
      taluks: ['Kolkata'],
    ),
    IndiaDistrict(
      name: 'Ahmedabad',
      stateCode: 'GJ',
      stateName: 'Gujarat',
      aliases: ['amdavad', 'ahd'],
      majorCities: ['Ahmedabad', 'Sanand', 'Dholera'],
      taluks: ['Ahmedabad City', 'Daskroi', 'Sanand', 'Dholka', 'Dhandhuka'],
    ),
    IndiaDistrict(
      name: 'New Delhi',
      stateCode: 'DL',
      stateName: 'Delhi',
      aliases: ['delhi', 'ncr'],
      majorCities: ['New Delhi', 'Connaught Place', 'Chanakyapuri'],
      taluks: ['Chanakyapuri', 'Delhi Cantonment', 'Vasant Vihar'],
    ),
  ];

  /// Get state by code or exact name/alias
  static IndiaState? findState(String query) {
    final clean = query.trim().toLowerCase();
    for (final s in allStatesAndUTs) {
      if (s.code.toLowerCase() == clean || s.name.toLowerCase() == clean) return s;
      if (s.aliases.any((a) => a.toLowerCase() == clean)) return s;
    }
    return null;
  }

  /// Get districts belonging to a state by name or code
  static List<IndiaDistrict> getDistrictsForState(String stateNameOrCode) {
    final clean = stateNameOrCode.trim().toLowerCase();
    final matchedState = findState(clean);
    final code = matchedState?.code ?? stateNameOrCode.toUpperCase();
    final name = matchedState?.name.toLowerCase() ?? clean;

    return districts.where((d) =>
      d.stateCode.toLowerCase() == code.toLowerCase() ||
      d.stateName.toLowerCase() == name
    ).toList();
  }

  /// Find district by name or alias
  static IndiaDistrict? findDistrict(String query, {String? stateNameOrCode}) {
    final clean = query.trim().toLowerCase();
    final stateScope = stateNameOrCode != null ? findState(stateNameOrCode) : null;

    for (final d in districts) {
      if (stateScope != null && d.stateCode != stateScope.code) continue;
      if (d.name.toLowerCase() == clean) return d;
      if (d.aliases.any((a) => a.toLowerCase() == clean)) return d;
    }
    return null;
  }

  /// Get taluks for a given district
  static List<String> getTaluksForDistrict(String districtName, {String? stateNameOrCode}) {
    final dist = findDistrict(districtName, stateNameOrCode: stateNameOrCode);
    return dist?.taluks ?? const [];
  }
}
