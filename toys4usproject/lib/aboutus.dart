import 'package:flutter/material.dart';


class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Text("About Us Page", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),),

          SizedBox(height: 10,),

          Text("we are a very honest business that relies on customer satisfaction above all and quality merchandize for the kids ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, ),),

          SizedBox(height: 20,),

          Text("Contact Us", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),),
          SizedBox(height: 10,),
          Text("(438) XXX-XXXX", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
          Text("toys4us@gmail.com", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
          Text("123avenuestrt yba xyz", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),

        ],
      )

    );
  }
}