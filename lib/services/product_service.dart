import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ProductModel>> fetchProducts() async {
    try {
      final data = await _client
          .from('products')
          .select('*') // WAJIB BINTANG
          .order("id");

      return (data as List).map((item) => ProductModel.fromMap(item)).toList();
    } catch (e) {
      print("FETCH PRODUCTS ERROR: $e");
      return [];
    }
  }
}
