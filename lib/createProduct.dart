import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_application/dashboard.dart';
import 'package:shopping_application/dataModel.dart';

class CreateProduct extends StatefulWidget {
  final Product? initialValue;

  CreateProduct({this.initialValue});
  @override
  _CreateProductState createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController topCategoryController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null) {
      topCategoryController.text = widget.initialValue!.topCategory ?? '';
      categoryController.text = widget.initialValue!.category ?? '';
      subCategoryController.text = widget.initialValue!.subCategory ?? '';
      productNameController.text = widget.initialValue!.productName ?? '';
      quantityController.text = '${widget.initialValue!.quantity}';
      priceController.text = widget.initialValue!.price.toString();
      statusController.text = 'Active';
    }
  }

  @override
  void dispose() {
    topCategoryController.dispose();
    categoryController.dispose();
    subCategoryController.dispose();
    productNameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    statusController.dispose();
    super.dispose();
  }

  Future<void> createOrUpdateProduct() async {
    final isEdit = widget.initialValue != null;
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('token');
    print('Get Token : ${accessToken}');

    // String token = 'd3fHdGwnRlSD3Nvq3OWnJlfc5zp0jDpKjTWXCS9GY5nnJl5F2UAX6Z3dqtnGhPpP';
    String _baseUrl = 'https://magenta-stingray-216844.hostingersite.com/api/product';
    final url = isEdit
        ? Uri.parse('$_baseUrl/update/${widget.initialValue!.id}')
        : Uri.parse('$_baseUrl/create');
    print('isEditing : $isEdit');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'top_category': topCategoryController.text,
        'category': categoryController.text,
        'sub_category': subCategoryController.text,
        'product_name': productNameController.text,
        'quantity': quantityController.text,
        'price': priceController.text,
        'status': 'Active',
      },
    );

    final responseData = json.decode(response.body);
    final message = responseData['status'] == 'success'
        ? (isEdit
            ? 'Product updated successfully!'
            : 'Product created successfully!')
        : responseData['message'] ?? 'Something went wrong';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    if (response.statusCode == 200 && responseData['status'] == 'success') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          maintainState: true,
          builder: (context) => DashboardScreen(
            email: prefs.getString('email').toString(),
          ),
        ),
            (route) => false, // Remove all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialValue !=null ? 'Edit Product' : 'Create Product'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(topCategoryController, 'Top Category'),
                _buildTextField(categoryController, 'Category'),
                _buildTextField(subCategoryController, 'Sub Category'),
                _buildTextField(productNameController, 'Product Name'),
                _buildTextField(quantityController, 'Quantity',isNumber: true),
                _buildTextField(priceController, 'Price',isNumber: true),
                // _buildTextField(statusController, 'Status',hint: 'Enter this format Active'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await createOrUpdateProduct();
                    }
                  },
                  child: Text('Submit', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,{bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}



/////////////////////////////
// Future<void> createProduct() async {
//   final url = Uri.parse('https://magenta-stingray-216844.hostingersite.com/api/product/create');
//   String token = 'KK5Mj1cnYgurDLdFp7yceOKuHQkBUVPSQ5j18athB9EnJD3woudX79rdhMarKREd';
//
//   final response = await http.post(
//     url,
//     headers: {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/x-www-form-urlencoded',
//     },
//     body: {
//       'top_category': topCategoryController.text,
//       'category': categoryController.text,
//       'sub_category': subCategoryController.text,
//       'product_name': productNameController.text,
//       'quantity': quantityController.text,
//       'price': priceController.text,
//       'status': statusController.text,
//     },
//   );
//
//   if (response.statusCode == 200) {
//     final prefs = await SharedPreferences.getInstance();
//     String email = prefs.getString('email') ?? '';
//     final responseData = json.decode(response.body);
//     final message = responseData['status'] == 'success'
//         ? 'Product created successfully!'
//         : responseData['message'] ?? 'Something went wrong';
//
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => DashboardScreen(email: email)), // Pass the email to Dashboard
//     );
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create product!')));
//   }
// }
