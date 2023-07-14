import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/provider/auth_provider.dart';
import 'package:quiz_app/screens/create_quiz_screen.dart';
import '../constants.dart';
import './profile_screen.dart';
import './quizes_list_screen.dart';
import '../widgets/custom_card_box.dart';
import '../provider/quizes_provider.dart';
import '../models/quiz_model.dart';
import '../widgets/custom_card.dart';
import './quiz_screen.dart';
import '../widgets/custom_page_route.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState(){
    super.initState();
    final qp = Provider.of<QuizesProvider>(context, listen: false);
    qp.getRecommendedQuizesFromFirestore(context: context)
      .whenComplete(() => qp.getCategoriesFromFirestore(context: context));
  }

  @override
  Widget build(BuildContext context) {

    final ap = Provider.of<AuthProvider>(context, listen: true);
    final qp = Provider.of<QuizesProvider>(context, listen: true);
    //? Gives the total height and width of the screen
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: customAppBar(ap),
      floatingActionButton: ap.userModel.role == "user" ? null : FloatingActionButton(
        backgroundColor: mainColor,
        child:const Icon(Icons.add),
        onPressed: (){
          Navigator.push(context, 
            CustomPageRoute(child: const CreateQuizScreen(), direction: AxisDirection.up),
          );
        },
      ),
      body: SingleChildScrollView(
        child: qp.isLoading 
          ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 100.0),
            child: Center(child: CircularProgressIndicator(color: mainColor)),
          ) 
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              topWidget(size),
              const SizedBox(height: 40),
              RecommendedQuizesSection(quizes: qp.getRecommendedQuizes, qp: qp),
              const CategorySection(),
            ],),
      ),
    );
  }

  AppBar customAppBar(ap) {
    return AppBar(
      toolbarHeight: 120,
      automaticallyImplyLeading: false,
      backgroundColor: mainColor,
      shadowColor: Colors.transparent,
      title: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget> [
            GestureDetector(
              onTap: (){
                Navigator.push(context, 
                  CustomPageRoute(child: const ProfileScreen(), direction: AxisDirection.right)
                );
              },
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.white),
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
                child: ap.userModel.profilePic == "" ? const Icon(Icons.account_circle, size: 51, color: Colors.white,) : null,
              ),
            ),
            const SizedBox(width: 15,),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text("Hello, ${ap.userModel.name}", overflow: TextOverflow.fade, style: const TextStyle(fontSize: 22)),
                  const Text("Let's start your quiz now !", style: TextStyle(fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
      // actions: [
      //   Padding(
      //     padding:const EdgeInsets.all(30.0),
      //     child: Row(
      //       children: [
      //         Container(
      //           width: 35,
      //           height: 35,
      //           decoration: BoxDecoration(
      //             color: Colors.white38,
      //             borderRadius: BorderRadius.circular(15),
      //           ),
      //           child: IconButton(
      //             onPressed: (){},
      //             splashRadius: 25,
      //             icon: const Icon(Icons.notifications, size: 18)
      //           ),
      //         ),
      //       ],
      //     ),
      //   )
      // ],
    );
  }

  Widget topWidget(size) => SizedBox(
      height: size.height * 0.25,
      child: Stack(
        children: <Widget> [
          Container(
            height: size.height * 0.2 - 27,
            decoration: const BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(36))
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              height: 200,
              decoration: BoxDecoration(
                color:const Color(0xff5ce4d2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0,10),
                    blurRadius: 50,
                    color: mainColor.withOpacity(0.23),
                  )
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:const [
                        Text("Quiz", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white )),
                        Text("Mania", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 5),
                        Text("Reclaim your brains with fun-filled trivia questions.", maxLines: 3, softWrap: true, style: TextStyle(fontSize: 12, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Image.asset("assets/quiz.png", height: 120)
                ]),
              ),
            )
          )
        ],
      ),
    );
}


class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {

    final qp = Provider.of<QuizesProvider>(context, listen: true);
    List<String> categories = qp.getCategories;

    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: Text("Category", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(26.0),
            child: Wrap(
              spacing: 20,runSpacing: 22,
              children: [
                for(int i = 0; i < categories.length; i++)
                  CustomCardBox(
                    title: categories[i].split(" ").map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(" "),
                    number: (i % card.length),
                    onTap: () {
                      qp.getQuizesBasedOnCategory(
                        context: context, 
                        category: categories[i], 
                        onSuccess: (){
                          Navigator.push(context,
                            CustomPageRoute(child: const QuizesListScreen(isRecommendedList: false), direction: AxisDirection.left)
                          );
                        }
                      );
                    }
                  ),
              ]
            ),
          )
        ],
      ),
    );
  }
}

class RecommendedQuizesSection extends StatelessWidget {
  const RecommendedQuizesSection({super.key, required this.quizes, required this.qp});

  final QuizesProvider qp;
  final List<Quiz> quizes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            children: [
              const Text("Recommended", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: (){
                  Navigator.push(context,
                    CustomPageRoute(child: const QuizesListScreen(isRecommendedList: true), direction: AxisDirection.left)
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  )
                ),
                child: const Text("More"),
              )
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:[
              for(int i = 0; i < 3 && i < quizes.length; i++)
                CustomCard(title: quizes[i].title, number: i + 1, 
                  onTap: (){
                    showDialog(context: context, 
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Column(
                            children: [
                              Text("Quiz: ${quizes[i].title}", textAlign: TextAlign.center),
                              const SizedBox(height: 10,),
                              Text("Questions: ${quizes[i].totalQuestions}", style: const TextStyle(fontSize: 14, color: Colors.black38), textAlign: TextAlign.center),
                              const SizedBox(height: 0,),
                            ],
                          ),
                          actions: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 40,
                                  child: CustomButton(text: "Cancel", onPressed: (){
                                    Navigator.pop(context);
                                  }),
                                ),
                                SizedBox(
                                  width: 100,
                                  height: 40,
                                  child: CustomButton(text: "START", onPressed: (){
                                    qp.setQuiz(i, true);
                                    Navigator.push(context, 
                                      CustomPageRoute(child: const QuizScreen(), direction: AxisDirection.right)
                                    );
                                  }),
                                ),
                            ],),
                          )
                        ],);
                      }
                    );
                }),
              const SizedBox(width: 27)
            ],
          ),
        )
      ]),
    );
  }
}

