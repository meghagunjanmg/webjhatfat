import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Components/custom_appbar.dart';
import 'package:jhatfat/HomeOrderAccount/Home/UI/appcategory/appcategory.dart';
import 'package:jhatfat/Routes/routes.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/nearstorebean.dart';
import 'package:jhatfat/bean/vendorbanner.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';

class StoresPage extends StatefulWidget {
  final String pageTitle;
  final dynamic vendor_category_id;

  StoresPage(this.pageTitle, this.vendor_category_id);

  @override
  State<StatefulWidget> createState() {
    return StoresPageState(pageTitle, vendor_category_id);
  }
}

class StoresPageState extends State<StoresPage> {
  final String pageTitle;
  final dynamic vendor_category_id;
  List<VendorBanner> listImage = [];
  List<NearStores> nearStores = [];
  List<NearStores> nearStoresSearch = [];
  List<NearStores> nearStoresShimmer = [

    NearStores("", "", 0, "", "", "", "", "", "", "", "", "","","","",""),
    NearStores("", "", 0, "", "", "", "", "", "", "", "", "","","","",""),
    NearStores("", "", 0, "", "", "", "", "", "", "", "", "","","","",""),
    NearStores("", "", 0, "", "", "", "", "", "", "", "", "","","","",""),
    NearStores("", "", 0, "", "", "", "", "", "", "", "", "","","","",""),

  ];
  List<String> listImages = ['', '', '', '', ''];
  bool isFetch = true;
  bool isFetchStore = true;

  StoresPageState(this.pageTitle, this.vendor_category_id);

  TextEditingController searchController = TextEditingController();
  bool isCartCount = false;
  int cartCount = 0;
  double userLat = 0.0;
  double userLng = 0.0;


  String message = '';
  Future<void> getdata() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState((){
      message = pref.getString("message")!;
    });
  }

  @override
  void initState() {
    getdata();
    getShareValue();
    super.initState();
    hitService();
    getCartCount();
  }

  getShareValue() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userLat = double.parse('${prefs.getString('lat')}');
      userLng = double.parse('${prefs.getString('lng')}');
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  String calculateTime(lat1, lon1, lat2, lon2){
    double kms = calculateDistance(lat1, lon1, lat2, lon2);
    double kms_per_min = 0.5;
    double mins_taken = kms / kms_per_min;
    double min = mins_taken;
    if (min<60) {
      return ""+'${min.toInt()}'+" mins";
    }else {
      double tt = min % 60;
      String minutes = '${tt.toInt()}';
      minutes = minutes.length == 1 ? "0" + minutes : minutes;
      return '${(min.toInt() / 60)}' + " hour " + minutes +"mins";
    }
  }

  Future<void> getCartCount() async {
    var store = intMapStoreFactory.store();
    var factory = databaseFactoryWeb;
    var db = await factory.openDatabase(DatabaseHelper.table);
    int size = await store.count(db);
    print("size "+size.toString());
    if(size==0){
      setState((){
        isCartCount = false;
        cartCount = size;
      });
    }
    else {
      setState(() {
        isCartCount = true;
        cartCount = size;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (searchController != null && searchController.text.length > 0) {
          setState(() {
            searchController.clear();
            nearStores.clear();
            nearStores = List.from(nearStoresSearch);
          });
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(110.0),
          child: CustomAppBar(
            titleWidget: Text(
              pageTitle,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Stack(
                  children: [
                    IconButton(
                        icon: ImageIcon(
                          AssetImage('images/icons/ic_cart blk.png'),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, PageRoutes.viewCart)
                              .then((value) {
                            getCartCount();
                          });

                        }),
                    // Positioned(
                    //     right: 5,
                    //     top: 2,
                    //     child: Visibility(
                    //       visible: isCartCount,
                    //       child: CircleAvatar(
                    //         minRadius: 4,
                    //         maxRadius: 8,
                    //         backgroundColor: kMainColor,
                    //         child: Text(
                    //           '$cartCount',
                    //           overflow: TextOverflow.ellipsis,
                    //           style: TextStyle(
                    //               fontSize: 7,
                    //               color: kWhiteColor,
                    //               fontWeight: FontWeight.w200),
                    //         ),
                    //       ),
                    //     ))
                  ],
                ),
              ),
            ],
            bottom: PreferredSize(
                child:
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 52,
                  padding: EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                      color: scaffoldBgColor,
                      borderRadius: BorderRadius.circular(50)),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search,
                        color: kHintColor,
                      ),
                      hintText: 'Search store...',
                    ),
                    controller: searchController,
                    cursorColor: kMainColor,
                    autofocus: false,
                    onChanged: (value) {
                      nearStores = nearStoresSearch
                          .where((element) => element.vendor_name
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                          .toList();
                    },
                  ),
                ),
                preferredSize:
                Size(MediaQuery.of(context).size.width * 0.85, 52)),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height - 110,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 20.0),
                  child: Text(
                    '${nearStores.length} Stores found',
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: kHintColor, fontSize: 18),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                (nearStores != null && nearStores.length > 0)
                    ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.separated(
                      shrinkWrap: true,
                      primary: false,
                      scrollDirection: Axis.vertical,
                      itemCount: nearStores.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if ((nearStores[index].online_status ==
                                "off" ||
                                nearStores[index].online_status == "Off" ||
                                nearStores[index].online_status ==
                                    "OFF")) {
                            }
                            else if(nearStores[index].inrange == 0){
                            }
                            else {
                              hitNavigator(
                                  context,
                                  nearStores[index].vendor_name,
                                  nearStores[index].vendor_id,
                                  nearStores[index].distance);
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Material(
                            elevation: 2,
                            shadowColor: white_color,
                            clipBehavior: Clip.hardEdge,
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                Container(
                                  width:
                                  MediaQuery.of(context).size.width,
                                  color: white_color,
                                  padding: EdgeInsets.only(
                                      left: 20.0, top: 15, bottom: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Image.network(
                                        imageBaseUrl +
                                            nearStores[index].vendor_logo,
                                        width: 93.3,
                                        height: 93.3,
                                      ),
                                      SizedBox(width: 13.3),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                                nearStores[index]
                                                    .vendor_name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2!
                                                    .copyWith(
                                                    color:
                                                    kMainTextColor,
                                                    fontSize: 18)),
                                            SizedBox(height: 8.0),
                                            Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.location_on,
                                                  color: kIconColor,
                                                  size: 15,
                                                ),
                                                SizedBox(width: 10.0),
                                                Text(
                                                    '${double.parse('${nearStores[index].distance}').toStringAsFixed(2)} km ',
                                                    style: Theme.of(
                                                        context)
                                                        .textTheme
                                                        .caption!
                                                        .copyWith(
                                                        color:
                                                        kLightTextColor,
                                                        fontSize:
                                                        13.0)),
                                                Text('| ',
                                                    style: Theme.of(
                                                        context)
                                                        .textTheme
                                                        .caption!
                                                        .copyWith(
                                                        color:
                                                        kMainColor,
                                                        fontSize:
                                                        13.0)),
                                                Expanded(
                                                  child: Text(
                                                      '${nearStores[index].vendor_loc}',
                                                      maxLines: 2,
                                                      style: Theme.of(
                                                          context)
                                                          .textTheme
                                                          .caption!
                                                          .copyWith(
                                                          color:
                                                          kLightTextColor,
                                                          fontSize:
                                                          13.0)),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 6),
                                            Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.access_time,
                                                  color: kIconColor,
                                                  size: 15,
                                                ),
                                                SizedBox(width: 10.0),
                                                Text('${nearStores[index].duration}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption!
                                                        .copyWith(
                                                        color:
                                                        kLightTextColor,
                                                        fontSize: 13.0)),
                                              ],
                                            ),

                                            Container(
                                              margin: EdgeInsets.all(8),
                                              child: Visibility(
                                                visible: (nearStores[index]
                                                    .online_status ==
                                                    "off" ||
                                                    nearStores[index]
                                                        .online_status ==
                                                        "Off" ||
                                                    nearStores[index]
                                                        .online_status ==
                                                        "OFF")
                                                    ? true
                                                    : false,
                                                child:
                                                Container(
                                                  margin: EdgeInsets.all(8),
                                                  height: 80,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                      10,
                                                  alignment: Alignment.center,
                                                  color: kCardBackgroundColor,
                                                  child: Text(
                                                    'Store open at ${nearStores[index].opening_time.toString()}',
                                                    style: TextStyle(
                                                        color: red_color,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.all(8),
                                              child: Visibility(
                                                visible: (nearStores[index]
                                                    .inrange == 0)
                                                    ? true
                                                    : false,
                                                child: Container(
                                                  margin: EdgeInsets.all(8),
                                                  height: 80,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                      10,
                                                  alignment: Alignment.center,
                                                  color: kCardBackgroundColor,
                                                  child: Text(
                                                    'Store Out of Delivery Range',
                                                    style: TextStyle(
                                                        color: red_color,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 10,
                        );
                      }),
                )
                    : Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      isFetchStore
                          ? CircularProgressIndicator()
                          : Container(
                        width: 0.5,
                      ),
                      isFetchStore
                          ? SizedBox(
                        width: 10,
                      )
                          : Container(
                        width: 0.5,
                      ),
                      Text(
                        (!isFetchStore)
                            ? 'No Store Found at your location'
                            : 'Fetching Stores',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: kMainTextColor),
                      )
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.all(12),
                  alignment: Alignment.bottomCenter,
                  child:    Text(
                    message.toString(),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  )
                  ,
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  void hitService() async {
    setState(() {
      isFetchStore = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = nearByStore;
    Uri myUri = Uri.parse(url);

    http.post(myUri, body: {
      'lat': '${prefs.getString('lat')}',
      'lng': '${prefs.getString('lng')}',
      'vendor_category_id': '${vendor_category_id}',
      'ui_type': '${prefs.getString('ui_type')}'
    }).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<NearStores> tagObjs = tagObjsJson
              .map((tagJson) => NearStores.fromJson(tagJson))
              .toList();
          setState(() {
            nearStores.clear();
            nearStoresSearch.clear();
            nearStores = tagObjs;
            nearStoresSearch = List.from(nearStores);
          });
        }
      }
      setState(() {
        isFetchStore = false;
      });
    }).catchError((e) {
      setState(() {
        isFetchStore = false;
      });
      Timer(Duration(seconds: 5), () {
        hitService();
      });
    });
  }

  void hitBannerUrl() async {
    var url = vendorBanner;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {'vendor_id': '$vendor_category_id'}).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<VendorBanner> tagObjs = tagObjsJson
              .map((tagJson) => VendorBanner.fromJson(tagJson))
              .toList();
          if (tagObjs.isNotEmpty) {
            setState(() {
              listImage.clear();
              listImage = tagObjs;
            });
          } else {
            setState(() {
              isFetch = false;
            });
          }
        } else {
          setState(() {
            isFetch = false;
          });
        }
      }
    }).catchError((e) {
      setState(() {
        isFetch = false;
      });
    });
  }

  showAlertDialog(BuildContext context, vendor_name, vendor_id, distance) {
    Widget clear = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        deleteAllRestProduct(context, vendor_name, vendor_id, distance);
      },
      child: Material(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            'Clear',
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    Widget no = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            'No',
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );
    AlertDialog alert = AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      title: Text("Inconvenience Notice"),
      content: Text(
          "Order from different store in single order is not allowed. Sorry for inconvenience"),
      actions: [clear, no],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  hitNavigator(BuildContext context, vendor_name, vendor_id, distance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isCartCount &&
        prefs.getString("vendor_id") != null &&
        prefs.getString("vendor_id") != "" &&
        prefs.getString("vendor_id") != '${vendor_id}') {
      ///showAlertDialog(context, vendor_name, vendor_id, distance);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AppCategory(vendor_name, vendor_id, distance))).then((value) {
        getCartCount();
      });
    }

    else {
      prefs.setString("vendor_id", '${vendor_id}');
      prefs.setString("store_name", '${vendor_name}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AppCategory(vendor_name, vendor_id, distance))).then((value) {
        getCartCount();
      });
    }
  }

  void deleteAllRestProduct(
      BuildContext context, vendor_name, vendor_id, distance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DatabaseHelper db = DatabaseHelper.instance;
    db.deleteAll().then((value) {
      prefs.setString("vendor_id", '${vendor_id}');
      prefs.setString("store_name", '${vendor_name}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AppCategory(vendor_name, vendor_id, distance))).then((value) {
        getCartCount();
      });
    });
  }
}
