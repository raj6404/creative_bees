import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:shopping_application/createProduct.dart';
import 'package:shopping_application/dataModel.dart';
import 'package:shopping_application/login.dart';

class DashboardScreen extends StatefulWidget {
  final String email;
  DashboardScreen({required this.email});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<ApiResponse> _apiResponse;

  List<Product> _cart = [];

  @override
  void initState() {
    super.initState();
    _fetchProductData();
    _loadCartFromPrefs();
  }

  void _loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? cartJson = prefs.getStringList('cart');

    if (cartJson != null) {
      setState(() {
        _cart = cartJson.map((item) => Product.fromJson(json.decode(item))).toList();
      });
    }
  }

  void _fetchProductData() {
    setState(() {
      _apiResponse = fetchProductData();
    });
  }

  // void _addToCart(Product product) {
  //   setState(() {
  //     if (!_cart.contains(product)) {
  //       _cart.add(product);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('${product.productName} added to cart!')),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('${product.productName} is already in the cart!')),
  //       );
  //     }
  //   });
  // }
  //
  // void _removeFromCart(Product product) {
  //   setState(() {
  //     _cart.remove(product);
  //   });
  // }

  void _addToCart(Product product) async {
    setState(() {
      if (!_cart.contains(product)) {
        _cart.add(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.productName} added to cart!')),
        );
        _saveCartToPrefs();  // Save cart after adding
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.productName} is already in the cart!')),
        );
      }
    });
  }

  void _removeFromCart(Product product) async {
    setState(() {
      _cart.remove(product);
      _saveCartToPrefs();  // Save cart after removing
    });
  }

  void _saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartJson = _cart.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('cart', cartJson);
  }


  void _viewCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          cart: _cart,
          onRemove: _removeFromCart,
        ),
      ),
    );
  }





  Future<ApiResponse> fetchProductData() async {
    final response = await http.get(Uri.parse('https://magenta-stingray-216844.hostingersite.com/api/product/read'));

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Welcome, ${widget.email}!', // Use the email passed to the constructor
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
        ),
        actions: [
          IconButton(
            onPressed: _viewCart,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 32),
                if (_cart.isNotEmpty)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        _cart.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            icon: Icon(
              Icons.exit_to_app,
              size: 28,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            CarouselSlider(
              items: [
                Image.asset('assets/images/shop.jpg', fit: BoxFit.cover),
                Image.asset('assets/images/pixels.jpg', fit: BoxFit.cover),
                Image.asset('assets/images/shoppingOnline.jpg', fit: BoxFit.cover),
              ],
              options: CarouselOptions(
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                enlargeCenterPage: true,
                aspectRatio: 1.5,
                viewportFraction: 1.0,
              ),
            ),
            SizedBox(height: 20),
            IconButton(onPressed: _viewCart, icon: Icon(Icons.shopping_cart_outlined)),
            Expanded(
              child: FutureBuilder<ApiResponse>(
                future: _apiResponse,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                    return Center(child: Text('No products available.'));
                  } else {
                    final products = snapshot.data!.data;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          item: products[index],
                          onTap: () {
                            // _showItemDetailsDialog(context, products[index]);
                          },
                          addCart:()=> _addToCart(products[index]),
                          onDelete: _fetchProductData,
                          isAdded: _cart.contains(products[index]),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateProduct()),
          ).then((_) => _fetchProductData());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showItemDetailsDialog(BuildContext context, Product item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item.productName!),
          content: Text(item.productName ?? 'No description available'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

}

class ProductCard extends StatelessWidget {
  final Product item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback addCart;
  final bool isAdded;

  ProductCard({required this.item, required this.onTap, required this.onDelete, required this.addCart, this.isAdded = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(children: [
        Card(
          elevation: 8,  // Slightly higher elevation for better shadow
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),  // More rounded corners
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  item.productName!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4), // Spacing between name and description

                // Product Description
                Text(
                  item.description ?? 'No description available',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(height: 10),

                // Product Price
                Text(
                  '\$${item.price}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),

                // Add to Cart Button at the bottom
                SizedBox(height: 10), // Adding some space before the button
                ElevatedButton(
                  onPressed: !isAdded ? addCart : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: !isAdded ? Colors.deepPurple : Colors.grey,  // Button color
                  ),
                  child: Text('Add to Cart', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 4, // Distance from the top
          right: 2, // Distance from the right
          child: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 22, color: Colors.grey),
            onSelected: (String value) {
              if (value == 'Edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateProduct(initialValue: item,)),
                );
              } else if (value == 'Delete') {
                deleteProduct(context,item.id);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'Delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],),
    );
  }

  Future<void> deleteProduct(BuildContext context,int productId) async {
    final url = Uri.parse('https://magenta-stingray-216844.hostingersite.com/api/product/delete/$productId');

    String token = 'KK5Mj1cnYgurDLdFp7yceOKuHQkBUVPSQ5j18athB9EnJD3woudX79rdhMarKREd';

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          print(responseData['message']); // Success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product deleted successfully!')),
          );
          onDelete();
        } else {
          print(responseData['message']); // Error message from API
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete product!')),
        );
      }
    } catch (error) {
      print('Error deleting product: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while deleting the product!')),
      );
    }
  }

}

class CartScreen extends StatefulWidget {
  final List<Product> cart;
  final Function(Product) onRemove;

  CartScreen({required this.cart, required this.onRemove});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Product> _cart;

  @override
  void initState() {
    super.initState();
    _cart = List.from(widget.cart); // Initialize the local cart with the passed cart
  }

  void _removeProduct(Product product) {
    setState(() {
      _cart.remove(product); // Remove the item from the cart and update UI
    });
    widget.onRemove(product); // Call the callback to remove the product from the parent
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: _cart.isEmpty
          ? Center(
        child: Text(
          'Your cart is empty.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: _cart.length,
        itemBuilder: (context, index) {
          final product = _cart[index];
          return ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text(product.productName!),
            subtitle: Text('\$${product.price}'),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () {
                _removeProduct(product); // Remove product and update the UI
              },
            ),
          );
        },
      ),
    );
  }
}



// return GridView.builder(
// gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// crossAxisCount: 2,
// crossAxisSpacing: 16,
// mainAxisSpacing: 16,
// childAspectRatio: 0.8, // Increased aspect ratio
// ),
// itemCount: 4,
// itemBuilder: (context, index) {
// return Shimmer.fromColors(
// baseColor: Colors.grey[300]!,
// highlightColor: Colors.grey[100]!,
// child: Card(
// elevation: 8,
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(16),
// ),
// child: Padding(
// padding: const EdgeInsets.all(16.0),
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Container(
// height: 120,
// width: double.infinity,
// color: Colors.grey[300],
// ),
// SizedBox(height: 10),
// Container(
// height: 20,
// width: 120,
// color: Colors.grey[300],
// ),
// SizedBox(height: 4),
// Container(
// height: 16,
// width: double.infinity,
// color: Colors.grey[300],
// ),
// SizedBox(height: 10),
// Container(
// height: 20,
// width: 80,
// color: Colors.grey[300],
// ),
// Spacer(),
// Container(
// height: 40,
// width: double.infinity,
// color: Colors.grey[300],
// ),
// ],
// ),
// ),
// ),
// );
// },
// );
