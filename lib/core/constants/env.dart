import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.dev', obfuscate: true)
abstract class EnvDev {
  @EnviedField(varName: 'SUPABASE_URL')
  static final String supabaseUrl = _EnvDev.supabaseUrl;
  
  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String supabaseAnonKey = _EnvDev.supabaseAnonKey;
  
  @EnviedField(varName: 'RAZORPAY_KEY')
  static final String razorpayKey = _EnvDev.razorpayKey;
  
  @EnviedField(varName: 'MAPS_API_KEY')
  static final String mapsApiKey = _EnvDev.mapsApiKey;
}

@Envied(path: '.env.stg', obfuscate: true)
abstract class EnvStg {
  @EnviedField(varName: 'SUPABASE_URL')
  static final String supabaseUrl = _EnvStg.supabaseUrl;
  
  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String supabaseAnonKey = _EnvStg.supabaseAnonKey;
  
  @EnviedField(varName: 'RAZORPAY_KEY')
  static final String razorpayKey = _EnvStg.razorpayKey;
  
  @EnviedField(varName: 'MAPS_API_KEY')
  static final String mapsApiKey = _EnvStg.mapsApiKey;
}

@Envied(path: '.env.prod', obfuscate: true)
abstract class EnvProd {
  @EnviedField(varName: 'SUPABASE_URL')
  static final String supabaseUrl = _EnvProd.supabaseUrl;
  
  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String supabaseAnonKey = _EnvProd.supabaseAnonKey;
  
  @EnviedField(varName: 'RAZORPAY_KEY')
  static final String razorpayKey = _EnvProd.razorpayKey;
  
  @EnviedField(varName: 'MAPS_API_KEY')
  static final String mapsApiKey = _EnvProd.mapsApiKey;
}
