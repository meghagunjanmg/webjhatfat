import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jhatfat/bean/adminsetting.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jhatfat/HomeOrderAccount/Account/UI/account_page.dart';
import 'package:jhatfat/HomeOrderAccount/Order/UI/order_page.dart';
import 'package:jhatfat/HomeOrderAccount/offer/ui/offerui.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/restaturantui/ui/resturanthome.dart';

import '../Pages/oneViewCart.dart';
import '../bean/bannerbean.dart';
import '../parcel/ParcelLocation.dart';
import 'Home/UI/home2.dart';

class HomeStateless extends StatelessWidget {
  int _currentIndex = 0;
  int _value = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeOrderAccount(this._currentIndex,this._value),
    );
  }
}

class HomeOrderAccount extends StatefulWidget {
  int _currentIndex = 0;
  int _value = 0;

  HomeOrderAccount(this._currentIndex,this._value);

  @override
  _HomeOrderAccountState createState() => _HomeOrderAccountState(_currentIndex,_value);
}

class _HomeOrderAccountState extends State<HomeOrderAccount> {
  int _currentIndex = 0;
  double bottomNavBarHeight = 60.0;
  //late CircularBottomNavigationController _navigationController;
  String ClosedImage = '';
  List<BannerDetails> ClosedBannerImage = [];
  Adminsetting? admins;
  int _value = 0;

  _HomeOrderAccountState(this._currentIndex,this._value);

  var lat = 0.0;
  var lng = 0.0;
  String? cityName = 'NO LOCATION SELECTED';
  List<Widget> _children = [];

  @override
  void initState() {
    super.initState();
    _requestPermission();
    getData();
    // _navigationController =
    // new CircularBottomNavigationController(_currentIndex);
    getCurrency();

    _children = [
      HomePage2(_value),
      Restaurant("Urbanby Resturant"),
      ///OrderPage(),
      ParcelLocation(),

      oneViewCart(),
      // ViewCart(),
    ];
  }

  void getData() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      cityName = pref.getString("addr")!;
      lat = double.parse(pref.getString("lat")!);
      lng = double.parse(pref.getString("lng")!);

      pref.setString("lat", lat.toString());
      pref.setString("lng", lng.toString());
      pref.setString("addr", cityName.toString());

      print("HOME_ORDER" + lat.toString() + lng.toString());
    } catch (e) {
      print(e);
    }
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      //openAppSettings();
    }
  }


  void getCurrency() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var currencyUrl = currencyuri;

    var client = http.Client();
    Uri myUri = Uri.parse(currencyUrl);
    client.get(myUri).then((value) {
      var jsonData = jsonDecode(value.body);
      if (value.statusCode == 200 && jsonData['status'] == "1") {
        preferences.setString(
            'curency', '${jsonData['data'][0]['currency_sign']}');
      }
    }).catchError((e) {
      print(e);
    });
  }
  //
  // List<TabItem> tabItems = List.of([
  //   new TabItem(Icons.home, "Home", Colors.blue, labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)),
  //    new TabItem(Icons.restaurant, "Resturant", Colors.blue, labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)),
  //  ///  new TabItem(Icons.reorder, "Order", Colors.blue,labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)),
  //    new TabItem(Icons.pin_drop, "Pick & Drop", Colors.blue,labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)),
  //    new TabItem(Icons.shopping_cart, "Cart", Colors.blue, labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 10)),
  // ]);


  void onTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
          onWillPop: () async {
            if(_currentIndex!=0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeOrderAccount(0,1)),

                    (Route<dynamic> route) => false,
              );
            }else{
              exit(0);
            }
            return true;
          },

          child:
          Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: _children,
            ),
            bottomNavigationBar: bottom2(context),
          ));
  }
  // Widget bottomNav(BuildContext context) {
  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     height: 80,
  //     color: kWhiteColor,
  //     child: CircularBottomNavigation(
  //       tabItems,
  //       controller: _navigationController,
  //       barHeight: 50,
  //       circleSize: 40,
  //       barBackgroundColor: kWhiteColor,
  //       iconsSize: 20,
  //       circleStrokeWidth: 5,
  //       animationDuration: const Duration(milliseconds: 300),
  //       selectedCallback: (int? selectedPos) {
  //         setState(() {
  //           _currentIndex = selectedPos!;
  //         });
  //
  //         if(selectedPos==3){
  //           Navigator.pushAndRemoveUntil(
  //               context,
  //               MaterialPageRoute(
  //                   builder: (context) => HomeOrderAccount(3,1)),
  //                   (Route<dynamic> route) => false);
  //         }
  //       },
  //     ),
  //   );
  //
  // }

  Widget bottom2(BuildContext context){
    return Container(
        height: 70,
        child: BottomNavigationBar(
          elevation: 20,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          selectedItemColor: kMainColor,
          unselectedItemColor: Colors.black,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 10),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 10),
          onTap: (value) {
            // Respond to item press.
            setState(() => _currentIndex = value);
            if(value==3){
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeOrderAccount(3,1)),
                      (Route<dynamic> route) => false);
            }
          },
          items: [
            BottomNavigationBarItem(
              label: 'Home',
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label: 'Restaurant',
              icon: Icon(Icons.restaurant),
            ),
            BottomNavigationBarItem(
              label: 'Pick & Drop',
              icon: Icon(Icons.location_on),
            ),
            BottomNavigationBarItem(
              label: 'Cart',
              icon: Icon(Icons.shopping_cart),
            ),
          ],
        )
    );
  }

}
