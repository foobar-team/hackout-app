class SliderData {
  String head;
  String body;
  String imagePath;

  SliderData({this.head,this.imagePath, this.body});
}

List<SliderData> get getSliderData {
  List<SliderData> list = [
    SliderData(
      head:"Call for help",
        body:
        "In a shady scenario? Call the citizens to your rescue. Alert the police and your loved ones in an instant.",
        imagePath: "assets/images/intro_one.png"),
    SliderData(
        head:"Help others",
        body:"Respond to distress calls. Help women in your locality.",
        imagePath: "assets/images/intro_two.png"),
    SliderData(
        head:"Track your loved ones",
        body:"Get the live location of your loved ones, get alerted when they are in distress",
        imagePath: "assets/images/intro_three.png"),
    SliderData(
        head:"Review localities",
        body:
        "Encountered an unsafe locality? Leave a review. Check others reviews of a locality.",
        imagePath: "assets/images/intro_four.png"),
    SliderData(
        head:"Get started",
        body:"Register with your email and unique identification (TBD: Aadhar or ?)",
        imagePath: "assets/images/intro_four.png"),

  ];
  return list;
}