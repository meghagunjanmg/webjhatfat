import 'cartitem.dart';

class OrderArray{

  int qty;
  int variant_id;


  OrderArray(this.qty, this.variant_id);

  @override
  String toString() {
    return '{\"qty\": $qty, \"variant_id\": $variant_id}';
  }
}

class OrderArrayGrocery{

  int qty;
  int varient_id;
  int basket;


  OrderArrayGrocery(this.qty, this.varient_id,this.basket);

  @override
  String toString() {
    return '{\"qty\": $qty, \"varient_id\": $varient_id, \"basket\": $basket}';
  }
}

class instructionbean{

  String vendor_name;
  String instruction;

  instructionbean(this.vendor_name, this.instruction);

  @override
  String toString() {
    return '{\"vendor_name\": $vendor_name, \"instruction\": $instruction}';
  }
}

class OrderAdonArray{
  int addonid;

  OrderAdonArray(this.addonid);

  @override
  String toString() {
    return '{\"addon_id\": $addonid}';
  }
}


class CartArray{

  dynamic vendor_id;
  dynamic vendor_name;
  List<CartItem> cartitems;
  dynamic subtotal;
  dynamic discount;

  CartArray(
      this.vendor_id, this.vendor_name, this.cartitems, this.subtotal,this.discount);

  @override
  String toString() {
    return 'CartArray{vendor_id: $vendor_id, vendor_name: $vendor_name, cartitems: $cartitems, subtotal: $subtotal,discount: $discount}';
  }
}