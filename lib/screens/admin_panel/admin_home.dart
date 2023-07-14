import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/provider/admin_control_provider.dart';
import 'package:quiz_app/screens/admin_panel/categories_screen.dart';
import 'package:quiz_app/widgets/custom_page_route.dart';
import 'package:quiz_app/screens/admin_panel/users_screen.dart';
import './quizes_screen.dart';
import '../../constants.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {

  @override
  void initState(){
    super.initState();
    final up = Provider.of<AdminControlProvider>(context, listen: false);
    up.getAllTheUsers(context: context)
      .whenComplete(() => up.getAllTheQuizes(context: context));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final up = Provider.of<AdminControlProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: mainColor,
        centerTitle: true,
        title: const Text("Admin Panel"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                buildCard(size.width - 45, 0, up.totalUsers, Icons.account_circle),
                buildCard(size.width - 45, 1, up.totalQuizes, Icons.quiz_rounded),
              ]
            ),
            const SizedBox(height: 20),
            buildNavigationField("Users", const UsersScreen(), Icons.manage_accounts_sharp),
            const Divider(color: Colors.black26),
            buildNavigationField("Quizes", const QuizesScreen(), Icons.quiz_outlined),
            const Divider(color: Colors.black26),
            buildNavigationField("Categories", const CategoriesScreen(), Icons.category),
            const Divider(color: Colors.black26),
          ],
        ),  
      ),
    );
  }

  Widget buildNavigationField(String label, Widget navigateTo, IconData icon){
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
          Navigator.push(context, 
            CustomPageRoute(child: navigateTo, direction: AxisDirection.left),
          );
        },
        child: Padding(
          padding:const EdgeInsets.symmetric(horizontal: 15, vertical: 22),
          child: Row(children: [
            Icon(icon, size: 25, color: Colors.black54),
            const SizedBox(width: 15,),
            Text(label, style: const TextStyle(color: Colors.black87, fontSize: 16),),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_right, color: Colors.black54,),
            const SizedBox(width: 12,),
          ],),
        ),
      ),
    );
  }

  Widget buildCard(double size, int number, int data, IconData icon){
    return Container(
      width: size / 2,
      height: size / 3,
      decoration: BoxDecoration(
        color: card[number],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(
          offset: const Offset(0, 5),
          blurRadius: 30,
          color: mainColor.withOpacity(0.23),
        )]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (){},
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Stack(
              children:<Widget> [
                Icon(icon, color: Colors.white.withOpacity(0.9), size: size / 7,),
                Positioned(
                  bottom: 0, right: 10,
                  child: Text(data.toString(), style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: size / 8),)
                )
            ]),
          )
        )
      )
    );
  }
}