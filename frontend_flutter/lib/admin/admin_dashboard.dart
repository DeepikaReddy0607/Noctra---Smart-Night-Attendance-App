import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget{
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title:const Text('Warden Dashboard'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Welcome Warden',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}