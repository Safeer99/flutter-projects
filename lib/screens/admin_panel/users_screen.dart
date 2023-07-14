import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/models/user_model.dart';
import 'package:quiz_app/provider/admin_control_provider.dart';
import 'package:quiz_app/provider/auth_provider.dart';
import 'package:quiz_app/utils/utils.dart';
import '../../constants.dart';
import '../../widgets/custom_page_route.dart';
import './user_details_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final up = Provider.of<AdminControlProvider>(context, listen: true);
    final admins = up.getUsersList.where((element) => element.role == "admin").toList();
    final users = up.getUsersList.where((element) => element.role != "admin").toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: mainColor,
        centerTitle: true,
        title: const Text("Users"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: admins.isEmpty ? null : const Text("Admins", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
            ),
            for(int i = 0; i < admins.length; i++)
              Column(
                children: [
                  buildNavigationField(context, 
                    admins[i],
                    (){
                      up.getUserResultsFromFirestore(context: context, uid: admins[i].uid, onSuccess:(){
                        Navigator.push(context, 
                          CustomPageRoute(child: UserDetails(user: admins[i]), direction: AxisDirection.left),
                        );
                      });
                    }
                  ),
                  const Divider(color: Colors.black26),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: users.isEmpty ? null : const Text("Users", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
            ),
            for(int i = 0; i < users.length; i++)
              Column(
                children: [
                  buildNavigationField(context, 
                    users[i],
                    (){
                      up.getUserResultsFromFirestore(context: context, uid: users[i].uid, onSuccess:(){
                        Navigator.push(context, 
                          CustomPageRoute(child: UserDetails(user: users[i]), direction: AxisDirection.left),
                        );
                      });
                    }
                  ),
                  const Divider(color: Colors.black26),
                ],
              ),
          ],
        ),  
      ),
    );
  }

  Widget buildNavigationField(BuildContext context, UserModel user, VoidCallback onTap){
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Row(children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                // border: Border.all(width: 2, color: mainColor.withOpacity(0.6)),
                boxShadow: [BoxShadow(
                  spreadRadius: 2,
                  blurRadius: 10,
                  color:mainColor.withOpacity(0.1)
                )],
                shape: BoxShape.circle,
                image: user.profilePic != "" ? DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(user.profilePic),
                ) : null,
              ),
              child: user.profilePic == "" ? const Icon(Icons.account_circle, size: 51, color: mainColor,) : null,
            ),
            const SizedBox(width: 15,),
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87, fontSize: 16),),
                  Text(user.email, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black45, fontSize: 12),),
                ],
              ),
            ),
            const SizedBox(width: 12,),
            Switch(value: user.role == "admin", activeColor: Colors.greenAccent.shade700, 
              onChanged: ap.uid == user.uid ? null : (onChange){
                UserModel newUser = user;
                newUser.role = user.role == "admin" ? "user" : "admin";
                final up = Provider.of<AdminControlProvider>(context, listen: false);
                up.updateUserRole(context: context, user: newUser, onSuccess: (){
                  showSnackBar(context, "Role changed successfully");
                });
            }),
            const SizedBox(width: 12,),
          ],),
        ),
      ),
    );
  }
}