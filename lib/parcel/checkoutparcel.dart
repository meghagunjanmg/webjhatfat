import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/paymentstatus.dart';
import 'package:jhatfat/parcel/parcelpaymentpage.dart';
import 'package:jhatfat/parcel/pharmacybean/parceladdress.dart';
import 'package:jhatfat/parcel/pharmacybean/parceldetail.dart';

class ParcelCheckOut extends StatefulWidget {
  final dynamic vendor_name;
  final dynamic vendor_id;
  final dynamic distance;
  final dynamic senderAddress;
  final dynamic receiverAddress;
  final dynamic charges;
  final dynamic cart_id;
  final dynamic description;

  ParcelCheckOut(
      this.vendor_id,
      this.vendor_name,
      this.distance,
      this.senderAddress,
      this.receiverAddress,
      this.charges,
      this.cart_id,
      this.description,

      );

  @override
  State<StatefulWidget> createState() {
    return ParcelCheckoutState();
  }
}

class ParcelCheckoutState extends State<ParcelCheckOut> {
  dynamic currency = '';

  int surge_charges = 0;
  int night_charges = 0;
  int conv_charges = 0;

  @override
  void initState() {
    getCurrency();
    servicecharge();

    super.initState();
  }

  void getCurrency() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currency = preferences.getString('curency');
    });
  }
  void servicecharge() async {
    var url = servicecharges;
    SharedPreferences pref = await SharedPreferences.getInstance();
    int? userId = pref.getInt('user_id');

    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'user_id': userId.toString(),
    }).then((value) {
      var jsonData = jsonDecode(value.body);
      print("SERVICE "+value.body.toString());
      if (jsonData['status'] == "1") {
        setState(() {
          surge_charges = jsonData['surge_charges'];
          night_charges = jsonData['night_charges'];
          conv_charges = jsonData['conv_charges'];
        });
      }
      else{
        setState(() {
          surge_charges = 0;
          night_charges = 0;
          conv_charges = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final ProgressDialog pr = ProgressDialog(context,
    //     type: ProgressDialogType.Normal, isDismissible: true, showLogs: true);
    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(52.0),
        child: AppBar(
          backgroundColor: kWhiteColor,
          titleSpacing: 0.0,
          title: Text(
            'Checkout',
            style: TextStyle(
                fontSize: 18, color: black_color, fontWeight: FontWeight.w400),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Sender Address',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Container(
              color: kWhiteColor,
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 10),
              child: Text('${widget.senderAddress.toString()}'),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Receiver Address',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Container(
              color: kWhiteColor,
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 10),
              child: Text('${widget.receiverAddress.toString()}'),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Parcel Description',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Container(
              color: kWhiteColor,
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 10),
              child: Text('${widget.description.toString()}'),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Distance Info',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Container(
              color: kWhiteColor,
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              padding:
              EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20, right: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Distance'),
                      Text(
                          '${double.parse('${widget.distance}')}'+' KM'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Payment Info',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),

            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                  vertical: 4.0, horizontal: 20.0),
              child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Parcel Charges',
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption,
                    ),
                    Text(
                      '${currency}'+'${widget.charges}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption,
                    ),
                  ]),
            ),

            (surge_charges>0)?
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                  vertical: 4.0, horizontal: 20.0),
              child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Surge Charge',
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption,
                    ),
                    Text(
                      '$currency ${surge_charges.toStringAsFixed(2)}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption,
                    ),
                  ]),
            ): Container(),
            (night_charges>0)?
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                  vertical: 4.0, horizontal: 20.0),
              child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Night Charge',
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption,
                    ),
                    Text(
                      '$currency ${night_charges.toStringAsFixed(2)}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption,
                    ),
                  ]),
            ): Container(),
            (conv_charges>0)?
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                  vertical: 4.0, horizontal: 20.0),
              child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Convenience Charge',
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption,
                    ),
                    Text(
                      '$currency ${conv_charges}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption,
                    ),
                  ]),
            ): Container(),

            SizedBox(
              height: 10,
            ),


            Container(
              color: kWhiteColor,
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              padding:
              EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20, right: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount to be paid '),
                      Text(
                          '${currency}'+'${widget.charges + surge_charges + night_charges + conv_charges}'),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: GestureDetector(
                onTap: () {
                  // showProgressDialog(
                  //     'please wait while we loading your request!', pr);
                  getVendorPayment(widget.vendor_id, context);
                },
                child: Card(
                  elevation: 2,
                  color: kMainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Container(
                    height: 52,
                    padding: EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width - 100,
                    child: Text(
                      'Proceed to payment',
                      style: TextStyle(fontSize: 18, color: kWhiteColor),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  // showProgressDialog(String text, ProgressDialog pr) {
  //   pr.style(
  //       message: '${text}',
  //       borderRadius: 10.0,
  //       backgroundColor: Colors.white,
  //       progressWidget: CircularProgressIndicator(),
  //       elevation: 10.0,
  //       insetAnimCurve: Curves.easeInOut,
  //       progress: 0.0,
  //       maxProgress: 100.0,
  //       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  //       progressTextStyle: TextStyle(
  //           color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
  //       messageTextStyle: TextStyle(
  //           color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
  // }

  void getVendorPayment(
      dynamic vendorId, BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currency = preferences.getString('curency');
    });
    var url = paymentvia;
    Uri myUri = Uri.parse(url);
    var client = http.Client();
    client.post(myUri, body: {'vendor_id': '${vendorId}'}).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          print('${value.statusCode} - ${value.body}');
          var tagObjsJson = jsonData['data'] as List;
          List<PaymentViaParcel> tagObjs = tagObjsJson
              .map((tagJson) => PaymentViaParcel.fromJson(tagJson))
              .toList();
          double? c = double.tryParse(widget.charges.toString());
          double? d = double.tryParse(widget.distance.toString());
          double? t = c! + surge_charges + night_charges + conv_charges;

          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PaymentParcelPage(
                widget.vendor_id,
                widget.cart_id,
                t!,
                tagObjs
            );
          }));
        }
      }
    }).catchError((e) {
      print(e);
    });
  }
}
