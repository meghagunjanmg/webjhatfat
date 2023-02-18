import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/Themes/constantfile.dart';
import 'package:jhatfat/Themes/style.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/bannerbean.dart';
import 'package:jhatfat/bean/nearstorebean.dart';
import 'package:jhatfat/bean/resturantbean/addonidlist.dart';
import 'package:jhatfat/bean/resturantbean/categoryresturantlist.dart';
import 'package:jhatfat/bean/resturantbean/popular_item.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';
import 'package:jhatfat/restaturantui/helper/add_to_cartbottomsheet.dart';
import 'package:jhatfat/restaturantui/helper/juice_list.dart';
import 'package:jhatfat/restaturantui/widigit/column_builder.dart';

import '../../HomeOrderAccount/Home/UI/home2.dart';
import '../../bean/cartitem.dart';
import '../../bean/venderbean.dart';

class ProductTabData extends StatefulWidget {
  final NearStores item;
final dynamic currencySymbol;
  final VoidCallback onVerificationDone;
  ProductTabData(this.item, this.currencySymbol,this.onVerificationDone);

  @override
  _ProductTabDataState createState() => _ProductTabDataState();
}

class _ProductTabDataState extends State<ProductTabData> {
  final itemKey = GlobalKey();
  final scrollController = ScrollController();
  int grocercart = 0;
  late AutoScrollController controller;
  final scrollDirection = Axis.vertical;

  List<CategoryResturant> categoryList = [];
  List<CategoryResturant> categoryList2 = [];
  List<PopularItem> popularItem = [];
  List<BannerDetails> listImage = [];
  bool isSlideFetch = false;
  bool isFetch = false;
  bool isFetchs = false;

  @override
  void initState() {
    // hitPopularitem();
    getCartItem();
    hitSliderUrl();
    hitResturantItem();
    super.initState();
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
  }
  void getCartItem() async {
    var store = intMapStoreFactory.store();
    var factory = databaseFactoryWeb;
    var db = await factory.openDatabase(DatabaseHelper.table);
    int size = await store.count(db);
    print("size "+size.toString());
    if(size==0){
      setState((){
        grocercart = 0;
      });
    }
    else {
      setState(() {
        grocercart = 1;
      });
    }
    // DatabaseHelper db = DatabaseHelper.instance;
    // db.queryAllRows().then((value) {
    //   List<CartItem> tagObjs =
    //   value.map((tagJson) => CartItem.fromJson(tagJson)).toList();
    //   if (tagObjs.isNotEmpty) {
    //     print("ALREADY G");
    //     setState(() {
    //       grocercart = 1;
    //     });
    //   }
    // });
  }
  void hitResturantItem() async {
    setState(() {
      isFetch = true;
    });
    print('${widget.item.vendor_id}');
    var url = homecategoryss;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'vendor_id': '${widget.item.vendor_id}'
    }).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<CategoryResturant> tagObjs = tagObjsJson
              .map((tagJson) => CategoryResturant.fromJson(tagJson))
              .toList();
          if (tagObjs != null && tagObjs.length > 0) {
            setState(() {
              isFetch = false;
              categoryList.clear();
              categoryList2.clear();
              categoryList = List.from(tagObjs);
              List<CategoryResturant> categoryListNew = List.from(tagObjs);
              categoryList2 = categoryListNew.toSet().toList();
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
      } else {
        setState(() {
          isFetch = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        isFetch = false;
      });
    });
  }

  void hitPopularitem() async {
    setState(() {
      isFetchs = true;
    });
    var url = popular_item;
    Uri myUri = Uri.parse(url);

    http.post(myUri, body: {
      'vendor_id': '${widget.item.vendor_id}'
    }).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('Response Body: - ${response.body}');
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<PopularItem> tagObjs = tagObjsJson
              .map((tagJson) => PopularItem.fromJson(tagJson))
              .toList();
          if (tagObjs != null && tagObjs.length > 0) {
            setState(() {
              isFetchs = false;
              popularItem.clear();
              popularItem = tagObjs;
            });
          } else {
            setState(() {
              isFetchs = false;
            });
          }
        } else {
          setState(() {
            isFetchs = false;
          });
        }
      } else {
        setState(() {
          isFetchs = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        isFetchs = false;
      });
    });
  }

  void hitSliderUrl() async {
    setState(() {
      isSlideFetch = true;
    });
    var url = resturant_banner;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'vendor_id': '${widget.item.vendor_id}'
    }).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('Response Body: - ${response.body}');
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<BannerDetails> tagObjs = tagObjsJson
              .map((tagJson) => BannerDetails.fromJson(tagJson))
              .toList();
          if (tagObjs != null && tagObjs.length > 0) {
            setState(() {
              isSlideFetch = false;
              listImage.clear();
              listImage = tagObjs;
            });
          } else {
            setState(() {
              isSlideFetch = false;
            });
          }
        } else {
          setState(() {
            isSlideFetch = false;
          });
        }
      } else {
        setState(() {
          isSlideFetch = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        isSlideFetch = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;
    return
      Scaffold(
          body:
          Container(
            margin: EdgeInsets.only(bottom: 80),
            child:
            (categoryList2 != null && categoryList2.length > 0)
                ?
            ListView.separated(
                shrinkWrap: true,
                primary: false,
                controller: controller,
                itemBuilder: (context, index) {
                  var item = categoryList2[index];
                  //var item = categoryList2[index].product_id;
                  print('${item.toString()}');
                  return AutoScrollTag(
                      key: ValueKey(index),
                      controller: controller,
                      index: index,
                      child:
                      Container(
                        color: kWhiteColor,
                        width: width,
                        child: Column(
                          children: [
                            Container(
                              width: width,
                              color: kWhiteColor,
                              child: Padding(
                                padding: EdgeInsets.all(fixPadding),
                                child: Text(
                                  '${item.cat_name}',
                                  style: headingStyle,
                                ),
                              ),
                            ),
                            Container(
                              color: kWhiteColor,
                              child: JuiceList(item,
                                  categoryList.where((element) => element
                                      .resturant_cat_id == item.resturant_cat_id)
                                      .toList(), widget.currencySymbol, () {
                                    widget.onVerificationDone();
                                  }),
                            ),
                            Container(
                              height: 10.0,
                              color: kWhiteColor,
                            ),
                          ],
                        ),
                      ));
                },
                separatorBuilder: (context, index) {
                  return Column(
                    children: [
                      heightSpace,
                      heightSpace,
                    ],
                  );
                },
                itemCount: categoryList2.length)
                :
            ListView.separated(
                shrinkWrap: true,
                primary: false,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        color: kWhiteColor,
                        child: Padding(
                          padding: EdgeInsets.all(fixPadding),
                          child: Shimmer(
                            duration: Duration(seconds: 3),
                            color: Colors.white,
                            enabled: true,
                            direction: ShimmerDirection.fromLTRB(),
                            child: Container(
                              width: 100.0,
                              height: 20.0,
                              color: kTransparentColor,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: kWhiteColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  right: fixPadding, left: fixPadding),
                              child: Shimmer(
                                duration: Duration(seconds: 3),
                                color: Colors.white,
                                enabled: true,
                                direction: ShimmerDirection.fromLTRB(),
                                child: Container(
                                  width: 100.0,
                                  height: 20.0,
                                  color: kTransparentColor,
                                ),
                              ),
                            ),
                            ColumnBuilder(
                              itemCount: 2,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              itemBuilder: (context, index) {
                                // final item = restaurantsList[index];
                                return Container(
                                  width: width,
                                  height: 105.0,
                                  margin: EdgeInsets.all(fixPadding),
                                  decoration: BoxDecoration(
                                    color: kWhiteColor,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned(
                                        right: fixPadding,
                                        child: InkWell(
                                          onTap: () {},
                                          child: Shimmer(
                                            duration: Duration(seconds: 3),
                                            color: Colors.white,
                                            enabled: true,
                                            direction:
                                            ShimmerDirection.fromLTRB(),
                                            child: Container(
                                              width: 22.0,
                                              height: 22.0,
                                              color: kTransparentColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: <Widget>[
                                          Shimmer(
                                            duration: Duration(seconds: 3),
                                            color: Colors.white,
                                            enabled: true,
                                            direction:
                                            ShimmerDirection.fromLTRB(),
                                            child: Container(
                                              width: 90.0,
                                              height: 100.0,
                                              color: kTransparentColor,
                                            ),
                                          ),
                                          Container(
                                            width: width -
                                                ((fixPadding * 2) + 100.0),
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: fixPadding * 2,
                                                      left: fixPadding,
                                                      bottom: fixPadding),
                                                  child: Shimmer(
                                                    duration:
                                                    Duration(seconds: 3),
                                                    color: Colors.white,
                                                    enabled: true,
                                                    direction: ShimmerDirection
                                                        .fromLTRB(),
                                                    child: Container(
                                                      height: 20.0,
                                                      color: kTransparentColor,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: fixPadding,
                                                      right: fixPadding),
                                                  child: Shimmer(
                                                    duration:
                                                    Duration(seconds: 3),
                                                    color: Colors.white,
                                                    enabled: true,
                                                    direction: ShimmerDirection
                                                        .fromLTRB(),
                                                    child: Container(
                                                      height: 20.0,
                                                      color: kTransparentColor,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: fixPadding,
                                                      left: fixPadding),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: <Widget>[
                                                      Shimmer(
                                                        duration: Duration(
                                                            seconds: 3),
                                                        color: Colors.white,
                                                        enabled: true,
                                                        direction:
                                                        ShimmerDirection
                                                            .fromLTRB(),
                                                        child: Container(
                                                          width: 100.0,
                                                          height: 20.0,
                                                          color:
                                                          kTransparentColor,
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          // productDescriptionModalBottomSheet(
                                                          //     context, height);
                                                        },
                                                        child: Container(
                                                          height: 20.0,
                                                          width: 20.0,
                                                          decoration:
                                                          BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                10.0),
                                                            color:
                                                            kTransparentColor,
                                                          ),
                                                          child: Shimmer(
                                                            duration: Duration(
                                                                seconds: 3),
                                                            color: Colors.white,
                                                            enabled: true,
                                                            direction:
                                                            ShimmerDirection
                                                                .fromLTRB(),
                                                            child: Container(
                                                              width: 15.0,
                                                              height: 15.0,
                                                              color:
                                                              kTransparentColor,
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
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 10.0,
                        color: kWhiteColor,
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return Column(
                    children: [
                      heightSpace,
                      heightSpace,
                    ],
                  );
                },
                itemCount: 10),
          ),
          floatingActionButton:
          Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10,vertical: 50),
                child: FloatingActionButton.extended(
                  onPressed: () { _showPopupMenu();},
                  icon: Icon(Icons.menu),
                  label: Text("Menu"),),
              )
          )

      );
  }
  _showPopupMenu(){
    showMenu<int>(
      context: context,
      elevation:10,
      position: RelativeRect.fromLTRB(1200,1200,1200,1200),      //position where you want to show the menu on screen
      items: List.generate(
        categoryList2.length,
            (index) => PopupMenuItem(
          value: index,
          child: Text(
            '${categoryList2[index].cat_name}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    ).then((value) async {
      if (value != null) {
        print(categoryList2[value].cat_name);
        await controller.scrollToIndex(value, preferPosition: AutoScrollPosition.begin);
      }
    });
  }

  showAlertDialog(BuildContext context, PopularItem item, currencySymbol,
      double height) {
    Widget clear = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        deleteAllRestProduct(context, item, currencySymbol, height);
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: red_color,
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: Text(
            'Clear', style: TextStyle(fontSize: 13, color: kWhiteColor),),
        ),
      ),
    );

    Widget no = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: kGreenColor,
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: Text(
            'No', style: TextStyle(fontSize: 13, color: kWhiteColor),),
        ),
      ),
    );
    AlertDialog alert = AlertDialog(
      title: Text("Inconvenience Notice"),
      content: Text(
          "Order from different store in single order is not allowed. Sorry for inconvenience"),
      actions: [
        clear,
        no
      ],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void deleteAllRestProduct(BuildContext context, PopularItem item,
      currencySymbol, double height) async {
    var store = intMapStoreFactory.store();
    var factory = databaseFactoryWeb;
    var db = await factory.openDatabase(DatabaseHelper.resturantOrder);
    var db1 = await factory.openDatabase(DatabaseHelper.addontable);
    await store.drop(db);
    await store.drop(db1);

        //
        // productDescriptionModalBottomSheet(
        //     context, height,item,widget.currencySymbol).then((value){
        //   widget.onVerificationDone();
        // });

  }

  void CallSearch(CategoryResturant categoryListNew, int index) {
    {
      print(index);
      DatabaseHelper db =
          DatabaseHelper.instance;
      db.getRestProdQty(
          '${categoryListNew.variant[0].variant_id}')
          .then((value) {
        if (value != null) {
          setState(() {
            categoryListNew.variant[0].addOnQty = value;
          });
        } else {
          if (categoryListNew.variant[0].addOnQty > 0) {
            setState(() {
              categoryListNew.variant[0].addOnQty = 0;
            });
          }
        }
      db.calculateTotalRestAdonA(
          '${categoryListNew.variant[0].variant_id}')
          .then((value1) {
        double priced = 0.0;
        if (value != null) {
          var tagObjsJson =
          value1 as List;
          dynamic totalAmount_1 =
          tagObjsJson[0]['Total'];
          if (totalAmount_1 != null) {
            setState(() {
              priced = double.parse(
                  '${totalAmount_1}');
            });
          }
        }



        db.getAddOnList(
            '${categoryListNew.variant[0].variant_id}')
            .then((valued) {
          List<AddonList> addOnlist = [];
          if (valued != null &&
              valued.length > 0) {
            addOnlist = valued
                .map((e) =>
                AddonList.fromJson(e))
                .toList();
            for (int i = 0;
            i < categoryListNew.addons.length;
            i++) {
              int ind = addOnlist.indexOf(
                  AddonList(
                      '${categoryListNew.addons[i].addon_id}'));
              if (ind != null && ind >= 0) {
                setState(() {
                  categoryListNew.addons[i].isAdd =
                  true;
                });
              }
            }
          }

          if(grocercart==1){
        print("ALREADY");
        showMyDialog(context);
      }
      else {
        productDescriptionModalBottomSheets(
            context,
            grocercart,
            MediaQuery
                .of(context)
                .size
                .height,
            categoryListNew,
            0, addOnlist,
            widget.currencySymbol,
            priced,
            widget
                .onVerificationDone())
            .then((value) {
          widget.onVerificationDone();
        });
      }
          });
        });
      });
    }
  }
  showMyDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            content: const Text(
              'Restraunt orders to be placed separately.\nPlease clear/empty cart to add item.in seperate orders',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Clear Cart'),
                onPressed: () {
                  ClearCart();

                  Navigator.of(context).pop(true);
                },
              ),

              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        }
    );
  }

  Future<void> ClearCart() async {
    var store = intMapStoreFactory.store();
    var factory = databaseFactoryWeb;
    var db = await factory.openDatabase(DatabaseHelper.table);
    await store.drop(db);
    setState(() {
      grocercart = 0;
    });
  }
}

  class BackendService {
  static Future<List<Vendors>> getSuggestions(String query,dynamic vendor_id) async {
  if (query.isEmpty && query.length < 2) {
  print('Query needs to be at least 3 chars');
  return Future.value([]);
  }

  var url = RestSearch_key;
  Uri myUri = Uri.parse(url);
  var response = await http.post(myUri, body: {
    'vendor_id':vendor_id.toString(),
   'prod_name': query
  });

  List<Vendors> vendors = [];
  List<Vendors> vendors1 = [];

  if (response.statusCode == 200) {
  Iterable json1 = jsonDecode(response.body)['restproduct'];
  Iterable json2 = jsonDecode(response.body)['restcat'];


  if (json1.isNotEmpty) {
  vendors.clear();
  vendors =
  List<Vendors>.from(json1.map((model) => Vendors.fromJson(model)));
  }
  if (json2.isNotEmpty) {
    vendors1.clear();
    vendors1 =
    List<Vendors>.from(json2.map((model) => Vendors.fromJson(model)));
    vendors.addAll(vendors1);
  }

  }

  return Future.value(vendors);
  }
}

