import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/provider/quizes_provider.dart';
import 'package:quiz_app/utils/utils.dart';
import 'package:quiz_app/widgets/custom_button.dart';
import 'package:quiz_app/widgets/custom_text_field.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {

  final _formField = GlobalKey<FormState>();
  final TextEditingController categoryController = TextEditingController();

  bool deleteMode = false;
  List<String> deleteList = [];

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    final qp = Provider.of<QuizesProvider>(context, listen: true);
    final List categories = qp.getCategories;

    categoryController.selection = TextSelection.fromPosition(TextPosition(offset: categoryController.text.length));

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: deleteMode ? Colors.red : mainColor,
        centerTitle: true,
        title: const Text("Categories"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: deleteMode ? IconButton(
              onPressed: (){
                qp.updateCategoriesInFirestore(context: context, categoriesList: deleteList)
                  .then((value){
                    setState((){
                      deleteMode = false;
                      deleteList = [];
                    });
                    showSnackBar(context, "Deleted successfully");
                  }).catchError((err) {
                    showSnackBar(context, err.toString());
                  });
              }, 
              icon: const Icon(Icons.delete)
            ) : null,
          )
        ],
      ),
      floatingActionButton: deleteMode ? null : FloatingActionButton(
        backgroundColor: mainColor,
        child:const Icon(Icons.add),
        onPressed: (){
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
            builder: (BuildContext context){
              return Container(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                    key: _formField,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('* For entering multiple values seperate them by "," (comma)', style: TextStyle(fontSize: 12, color: Colors.black45),),
                        const SizedBox(height: 20,),
                        CustomTextField(
                          hintText: "Enter Category",
                          icon: Icons.category,
                          iconDisplay: true,
                          controller: categoryController,
                        ),
                        const SizedBox(height: 20,),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: CustomButton(text: "Submit", onPressed: (){
                            if(_formField.currentState!.validate()){
                              qp.updateCategoriesInFirestore(context: context, categoriesList: categoryController.text.trim().split(",").map((e) => e.trim()).toList())
                                .then((value){
                                  showSnackBar(context, "Category added successfully");
                                  Navigator.pop(context);
                                }).catchError((err) {
                                  showSnackBar(context, err.toString());
                                  Navigator.pop(context);
                                });
                              categoryController.clear();
                            }
                          })
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: size.width,
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              for(int i = 0; i < categories.length; i++)
                buildCategoryCard(categories[i].split(" ").map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(" "), i%3,
                  (){//! onLongPress
                    setState((){
                      deleteMode = true;
                      deleteList.add(categories[i]);
                    });
                  }, 
                  (){//! onTap
                    if(deleteMode){
                      setState((){
                        if(deleteList.contains(categories[i])){
                          deleteList.remove(categories[i]);
                          if(deleteList.isEmpty){
                            deleteMode = false;
                          }
                        }else {
                          deleteList.add(categories[i]);
                        }
                      });
                    }
                  },
                ),
            ],  
          ),
        ),
      ),
    );
  }

  Widget buildCategoryCard(String label, int number, VoidCallback onLongPress, VoidCallback onTap){
    Size size = MediaQuery.of(context).size;
    return Container(
      width: (size.width-80) /3,
      height: (size.width-80) /3,
      decoration: BoxDecoration(
        color: card[number],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(
          offset: const Offset(0, 5),
          blurRadius: 30,
          color: mainColor.withOpacity(0.23),
        )]
      ),
      child: Material(
        color: deleteList.contains(label.toLowerCase()) ? Colors.white54 : Colors.transparent,
        child: InkWell(
          onLongPress: onLongPress,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(children:[
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),),
              Positioned(
                top: 0,bottom: 0,left: 0,right: 0,
                child: Icon(Icons.category, color: Colors.white24, size: size.width/9)
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Icon(deleteList.contains(label.toLowerCase()) ? Icons.check_circle : Icons.circle_outlined, color: deleteMode ? Colors.white : Colors.transparent)
              ),
            ],),
          ),
        ),
      ),
    );
  }
}