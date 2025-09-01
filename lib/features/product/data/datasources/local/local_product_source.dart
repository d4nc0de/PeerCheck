import '../../../domain/models/product.dart';
import '../i_remote_product_source.dart';

class LocalProductSource implements IProductSource {
  final List<Product> _products;

  LocalProductSource()
      : _products = [
          Product(
            id: '1',
            name: 'Programación Móvil',
            description: 'Augusto Salazar',
            quantity: 5566,
          ),
          Product(
            id: '2',
            name: 'Bases de Datos',
            description: 'Carlos Ruiz',
            quantity: 7788,
          ),
        ];

  @override
  Future<bool> addProduct(Product product) {
    product.id = DateTime.now().millisecondsSinceEpoch.toString();
    _products.add(product);
    return Future.value(true);
  }

  @override
  Future<bool> deleteProduct(Product product) {
    _products.remove(product);
    return Future.value(true);
  }

  @override
  Future<bool> deleteProducts() {
    _products.clear();
    return Future.value(true);
  }

  @override
  Future<List<Product>> getProducts() {
    // siempre devuelve la lista actual (con las quemadas iniciales)
    return Future.value(_products);
  }

  @override
  Future<bool> updateProduct(Product product) {
    var index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      return Future.value(true);
    }
    return Future.value(false);
  }
}
