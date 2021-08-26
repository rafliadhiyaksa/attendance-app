import 'package:flutter/material.dart';
import 'package:presensi_app/widgets/navigation_bar.dart';
import 'package:supercharged/supercharged.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final Color primary = '3546AB'.toColor();

  @override
  Widget build(BuildContext context) {
    double cardHeight = MediaQuery.of(context).size.height * 0.2;
    double cardWidth = MediaQuery.of(context).size.width - 20;
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: primary,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),

                      child: Container(
                        color: Colors.white,
                        width: cardWidth * 0.38,
                        child: Image.asset(''),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText(
                            "Rafli Adhiyaksa Putra",
                            20,
                            Colors.white,
                          ),
                          buildText("Software Developer", 15, Colors.white),
                          Spacer(),
                          Container(
                            width: cardWidth * 0.45,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: primary,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.white, width: 2.0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {},
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.visibility_rounded,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    buildText("Detail", 18, Colors.white)
                                  ],
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Text buildText(String text, double size, Color color,
      {int? maxLines, TextOverflow? overflow}) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontFamily: "ProductSans",
        fontSize: size,
        fontWeight: FontWeight.w700,
      ),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
