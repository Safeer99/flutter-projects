import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quiz_app/models/user_model.dart';
// import 'package:quiz_app/provider/quizes_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../constants.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import './login_screen.dart';
import '../utils/utils.dart';
import '../widgets/custom_button.dart';
import './history_screen.dart';
import '../widgets/custom_page_route.dart';
import './admin_panel/admin_home.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final _formField = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  File? _imageFile;

  Future<bool> cropImage() async {
    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: _imageFile?.path ?? "",
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Photo",
          toolbarColor: mainColor,
          toolbarWidgetColor: Colors.white,
        )
      ],
      aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 4),
    );
    setState(() {
      _imageFile = File(cropped?.path ?? _imageFile?.path ?? "");
    });

    if(cropped != null){
      return true;
    }
    return false;
  }

  Future<void> pickImage(ImageSource source) async{
    final selected = await ImagePicker().pickImage(source: source);
    if(selected != null){
      setState(() {
        _imageFile = File(selected.path);
      });
    }
  }

  @override
  void dispose(){
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final ap = Provider.of<AuthProvider>(context, listen: true);
    // final qp = Provider.of<QuizesProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: mainColor,
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: const Text("Profile"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: IconButton(
              onPressed: (){
                // qp.readJson();
                ap.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder:  (context) => const LoginScreen(),), 
                    (route) => false
                );
              },
              icon: const Icon(Icons.logout)
            )
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(top:10),
        child: GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: ap.isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.white)) 
            : Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(child: Stack(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(width: 4, color: Colors.white),
                      boxShadow: [BoxShadow(
                        spreadRadius: 2,
                        blurRadius: 10,
                        color:Colors.black.withOpacity(0.1)
                      )],
                      shape: BoxShape.circle,
                      image:  ap.userModel.profilePic != "" ? DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(ap.userModel.profilePic),
                      ) : null,
                    ),
                    child: ap.userModel.profilePic == "" ? const Icon(Icons.account_circle, size: 140, color: Colors.white,) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width:3, color: Colors.white),
                        color: mainColor,
                      ),
                      child: IconButton(
                        onPressed: (){
                          showModalBottomSheet(
                            isDismissible: true,
                            isScrollControlled: true,
                            enableDrag: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10)
                              )
                            ),
                            context: context,
                            builder: (BuildContext context){return Padding(
                              padding: const EdgeInsets.all(30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    onPressed: (){
                                      pickImage(ImageSource.camera)
                                        .whenComplete(() {
                                          cropImage().then((value) { if(value) sendData(); });
                                        }).catchError((e){
                                          showSnackBar(context, e.message.toString());
                                        });
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.photo_camera, color: mainColor,),
                                  ),
                                  IconButton(
                                    onPressed: (){
                                      pickImage(ImageSource.gallery)
                                        .whenComplete(() {
                                          cropImage().then((value) { if(value) sendData(); });
                                        }).catchError((e){
                                          showSnackBar(context, e.message.toString());
                                        });
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.photo_library, color: mainColor),
                                  ),
                                ]
                              )
                            );}
                          );
                          
                        },
                        splashColor: Colors.white60,
                        splashRadius: 25,
                        icon: const Icon(Icons.photo_camera, color: Colors.white),
                      ),
                    )
                  ),
                ],
              ),),
              const SizedBox(height: 30),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration:const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                  ),
                  child: ListView(
                    children: [
                      buildDataField("Name", ap.userModel.name, Icons.account_circle_outlined, (){
                        nameController.text = ap.userModel.name;
                        showModalBottomSheet(
                          isDismissible: true,
                          isScrollControlled: true,
                          enableDrag: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20)
                            )
                          ),
                          context: context,
                          builder: (BuildContext context){return bottomSheet("Name", ap.userModel.name, nameController);}
                        );
                      }, true),
                      const Divider(color: Colors.black26),
                      buildDataField("Email", ap.userModel.email, Icons.email_rounded, (){}, false),
                      const Divider(color: Colors.black26),
                      buildNavigationField("History", const HistoryScreen(), Icons.history),
                      const Divider(color: Colors.black26),
                      if(ap.userModel.role == "admin")
                        buildNavigationField("Admin panel", const AdminHome(), Icons.admin_panel_settings),
                        const Divider(color: Colors.black26),
                    ],
                  )
                ),
              )
            ],
          )
        ),
      )
    );
  }

  Widget buildDataField(String label, String text, IconData icon, VoidCallback onPressed, bool iconDisplay) {
    return Padding(
      padding:const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(icon, size: 25, color: Colors.black54,),
                      const SizedBox(width: 15,),
                      Text(label, style: const TextStyle(fontSize: 13, color: Colors.black45),),
                    ],
                  ),
                  const SizedBox(height: 5,),
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87, fontSize: 15),),
                  ),
              ]),
            ),
          ),
          if(iconDisplay)
            Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: onPressed,
                splashRadius: 25,
                icon: const Icon(Icons.edit, color: Colors.black54,),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildNavigationField(String label, Widget navigateTo, IconData icon){
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
          Navigator.push(context, 
            CustomPageRoute(child: navigateTo, direction: AxisDirection.left)
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

  Widget bottomSheet(String hintText, String data, TextEditingController controller){
    nameController.selection = TextSelection.fromPosition(TextPosition(offset: nameController.text.length));
    
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
        child: Form(
          key: _formField,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children:[
              Text("Enter your $hintText", style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 20),
              TextFormField(
                cursorColor: mainColor,
                controller: controller,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500),
                  focusColor: mainColor,
                ),
                validator: (value) {
                  if(value!.isEmpty){
                    return "Fill this field";
                  }
                  return null;
                }
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(width: 100, height: 40, child: CustomButton(text: "Cancel", onPressed: (){Navigator.pop(context);},)),
                  const SizedBox(width: 20),
                  SizedBox(width: 100, height: 40, child: CustomButton(text: "Save", onPressed: (){
                    if(_formField.currentState!.validate()){
                      sendData();
                      Navigator.pop(context);
                    }
                  },)),
                ],
              )
            ]
          ),
        ),
      )
    );
  }

  void sendData() {
      final ap = Provider.of<AuthProvider>(context, listen: false);

      UserModel user = ap.userModel;
      user.name = nameController.text != "" ? nameController.text : ap.userModel.name;

      nameController.clear();

      if(_imageFile != null){
        ap.uploadProfilePic(context: context, profilePic: _imageFile!, onSuccess: (value){
          user.profilePic = value;
          ap.updateUserDataOnFirebase(context: context, user: user, onSuccess: (){
            showSnackBar(context, "Updated Successfully");
            ap.saveUserDataToSP();
          });
        });
      }else{
        ap.updateUserDataOnFirebase(context: context, user: user, onSuccess: (){
          showSnackBar(context, "Updated Successfully");
          ap.saveUserDataToSP();
        });
      }
  }

}
