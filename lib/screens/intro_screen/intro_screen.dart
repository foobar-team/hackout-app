import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:foobar/screens/intro_screen/intro_screen_data.dart';
import 'package:foobar/screens/signup_screen.dart';
import 'package:transparent_image/transparent_image.dart';

int currentIndex = 0;
PageController pageController = PageController();
// Image droogLogo;
List<SliderData> listData;

class IntroductionScreen extends StatefulWidget {
  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listData = getSliderData;
    // droogLogo = Image.asset(
    //   "assets/images/droog_logo.png",
    //   height: 70,
    //   width: 70,
    //   cacheHeight: 512,
    //   cacheWidth: 512,
    // );
  }

  @override
  Widget build(BuildContext context) {
    // precacheImage(droogLogo.image, context);
    return Scaffold(
      bottomSheet: currentIndex == listData.length - 1
          ? GestureDetector(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, SignUpScreen.route),
              child: Container(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Get Started",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                color: Colors.blueGrey,
                width: double.infinity,
                height: 50,
              ),
            )
          : Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: NeumorphicButton(
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.black,
                      ),
                      style: NeumorphicStyle(
                        color: Colors.white,
                        depth: 50,
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.circle(),
                      ),
                      onPressed: () {pageController.previousPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease);},
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DotsIndicator(
                      dotsCount: 5,
                      position: currentIndex.toDouble(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: NeumorphicButton(
                        child: Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        style: NeumorphicStyle(
                          color: Colors.black,
                          depth: 50,
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.circle(),
                        ),
                        onPressed: () {
                          pageController.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease);
                        }),
                  ),
                ],
              ),
            ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (ctx, index) {
                return SliderTile(
                  head: listData[index].head,
                  body: listData[index].body,
                  imagePath: listData[index].imagePath,
                );
              },
              itemCount: listData.length,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container()
                  // NeumorphicText(
                  //   "HelpHer",
                  //   style: NeumorphicStyle(
                  //     shape: NeumorphicShape.flat,
                  //     depth: 50, //customize depth here
                  //     color: Colors.blueGrey, //customize color here
                  //   ),
                  //   textStyle: NeumorphicTextStyle(fontSize: 50),
                  // ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SliderTile extends StatelessWidget {
  final String head;
  final String body;
  final String imagePath;

  // final Image logo;

  SliderTile({
    this.head,
    this.body,
    this.imagePath,
  });

  TextStyle textStyle = TextStyle(
    fontSize: 19,
    color: Color(0xfffdf9f9),
    fontWeight: FontWeight.w400,
  );

  @override
  Widget build(BuildContext context) {
    final heightAvailable =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FadeInImage(
              image: AssetImage(
                imagePath,
              ),
              width: double.infinity,
              height: (heightAvailable) * .6,
              placeholder: MemoryImage(kTransparentImage),
            ),
//            Image.asset(
//              imagePath,
//              width: double.infinity,
//              height: (heightAvailable) * .6,
//            ),
          Text(head,textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold

            ),),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  body,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,

                  ),
                ),
            ),

          ],
        ),
      ),
    );
  }
}
