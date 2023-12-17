import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Order App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: OrderScreen(),
    );
  }
}

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<Order> orders = [];
  List<Order> filteredOrders = [];
  String selectedSupplier = 'All Suppliers';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      var response = await http.get(Uri.parse('https://z7y6q.wiremockapi.cloud/orders'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<Order> fetchedOrders = [];

        for (var orderData in data['data']) {
          Order order = Order(
            orderBuyerStatus: orderData['orderBuyerStatus'],
            deliveryDay: orderData['deliveryDay'],
            vendorName: orderData['vendorName'],
            isPendingVendorOnboarding: orderData['isPendingVendorOnboarding'],
            isBYOS: orderData['isBYOS'],
            total: orderData['total'], // Assuming API provides int or double
          );
          fetchedOrders.add(order);
        }

        setState(() {
          orders = fetchedOrders;
          filteredOrders = fetchedOrders;
        });
      } else {
        print('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void filterOrdersBySupplier(String supplier) {
    setState(() {
      selectedSupplier = supplier;
      if (supplier == 'All Suppliers') {
        filteredOrders = orders;
      } else {
        filteredOrders = orders.where((order) => order.vendorName == supplier).toList();
      }
    });
  }

  Widget buildOrderContainer(Order order) {
    Color statusColor = Colors.grey[200] ?? Colors.transparent;
    Color background = Colors.white;

    if (order.orderBuyerStatus == 'Processing') {
      statusColor = Colors.green; // Set Processing status to green
    } else if (order.orderBuyerStatus == 'Processed') {
      statusColor = Colors.blue; // Set Processed status to blue
    }

    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4), // Shadow color and opacity
            spreadRadius: 2, // Spread radius
            blurRadius: 5, // Blur radius
            offset: Offset(0, 3), // Offset of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Status: ${order.orderBuyerStatus}',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: 8.0),
          Text('Delivery Day: ${_formatDeliveryDay(order.deliveryDay)}'),
          SizedBox(height: 8.0),
          Text('Supplier: ${order.vendorName}'),
          SizedBox(height: 8.0),
          if (order.isPendingVendorOnboarding) Text('1st'),
          if (!order.isBYOS) Text('Market'),
          SizedBox(height: 8.0),
          if (order.total != null) Text('Total: \$${order.total}'),
        ],
      ),
    );
  }

  String _formatDeliveryDay(String deliveryDay) {
    return deliveryDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.info),
          onPressed: () {
            // Add functionality for the info button
          },
        ),
        centerTitle: true,
        title: Text('Orders'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'), // Path to your background image
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('All Suppliers'),
                    Icon(Icons.navigate_next), // Icon at the end
                  ],
                ),
                onTap: () {
                  filterOrdersBySupplier('All Suppliers');
                  Navigator.pop(context);
                },
              ),
              ...orders.map((order) => order.vendorName).toSet().map((supplier) {
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(supplier),
                      Icon(Icons.navigate_next), // Icon at the end
                    ],
                  ),
                  onTap: () {
                    filterOrdersBySupplier(supplier);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                return buildOrderContainer(filteredOrders[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Order {
  final String orderBuyerStatus;
  final String deliveryDay;
  final String vendorName;
  final bool isPendingVendorOnboarding;
  final bool isBYOS;
  final num? total;

  Order({
    required this.orderBuyerStatus,
    required this.deliveryDay,
    required this.vendorName,
    required this.isPendingVendorOnboarding,
    required this.isBYOS,
    this.total,
  });
}
