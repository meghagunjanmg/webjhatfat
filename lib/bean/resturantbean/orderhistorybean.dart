
class OrderHistoryRestaurant{

  dynamic order_status;
  dynamic delivery_date;
  dynamic time_slot;
  dynamic payment_method;
  dynamic payment_status;
  dynamic paid_by_wallet;
  dynamic cart_id;
  dynamic price;
  dynamic delivery_charge;
  dynamic remaining_amount;
  dynamic coupon_discount;
  dynamic delivery_boy_name;
  dynamic delivery_boy_phone;
  dynamic vendor_name;
  dynamic address;
  dynamic delivery_lat;
  dynamic delivery_lng;
  dynamic vendor_lat;
  dynamic vendor_lng;
  List<ProductItemList> data;

  dynamic surgecharge;
  dynamic nightcharge;
  dynamic convcharge;
  dynamic gst;
  dynamic price_without_delivery;


  OrderHistoryRestaurant(
      this.order_status,
      this.delivery_date,
      this.time_slot,
      this.payment_method,
      this.payment_status,
      this.paid_by_wallet,
      this.cart_id,
      this.price,
      this.delivery_charge,
      this.remaining_amount,
      this.coupon_discount,
      this.delivery_boy_name,
      this.delivery_boy_phone,
      this.vendor_name,
      this.address,
      this.delivery_lat,
      this.delivery_lng,
      this.vendor_lat,
      this.vendor_lng,

      this.data,
      this.surgecharge,
      this.nightcharge,
      this.convcharge,
      this.price_without_delivery,
      this.gst,
      );

  factory OrderHistoryRestaurant.fromJson(dynamic json){
    var jsonList = json['data'] as List;
    List<ProductItemList> data1 = [];
    if(jsonList!=null && jsonList.length>0){
      data1 = jsonList.map((e) => ProductItemList.fromJson(e)).toList();
    }
    return OrderHistoryRestaurant(json['order_status'], json['delivery_date'], json['time_slot'], json['payment_method'], json['payment_status'], json['paid_by_wallet'], json['cart_id'], json['price'], json['delivery_charge'], json['remaining_amount'], json['coupon_discount'], json['delivery_boy_name'], json['delivery_boy_phone'], json['vendor_name'], json['address'],json['delivery_lat'],json['delivery_lng'],json['vendor_lat'],json['vendor_lng'], data1,  json['surgecharge'] ,json['nightcharge']   , json ['convcharge'],json['price_without_delivery'],json['gst'] );
  }

  @override
  String toString() {
    return '{order_status: $order_status, delivery_date: $delivery_date, time_slot: $time_slot, payment_method: $payment_method, payment_status: $payment_status, paid_by_wallet: $paid_by_wallet, cart_id: $cart_id, price: $price, delivery_charge: $delivery_charge, remaining_amount: $remaining_amount, coupon_discount: $coupon_discount, delivery_boy_name: $delivery_boy_name, delivery_boy_phone: $delivery_boy_phone, vendor_name: $vendor_name, address: $address,delivery_lat: $delivery_lat,delivery_lng: $delivery_lng,vendor_lat: $vendor_lat,vendor_lng: $vendor_lng, data: $data,surgecharge :$surgecharge,nightcharge:$nightcharge,convcharge:$convcharge,price_without_delivery:$price_without_delivery,gst: $gst }';
  }
}


class ProductItemList{

  dynamic store_order_id;
  dynamic product_name;
  dynamic quantity;
  dynamic unit;
  dynamic varient_id;
  dynamic qty;
  dynamic price;
  dynamic total_mrp;
  dynamic order_cart_id;
  dynamic order_date;
  dynamic varient_image;
  dynamic addon_id;
  dynamic addon_price;
  dynamic addon_name;

  ProductItemList(this.store_order_id, this.product_name, this.quantity,
      this.unit, this.varient_id, this.qty, this.price, this.total_mrp,
      this.order_cart_id, this.order_date, this.varient_image, this.addon_id,
      this.addon_price, this.addon_name);

  factory ProductItemList.fromJson(dynamic json){
    return ProductItemList(json['store_order_id'], json['product_name'], json['quantity'], json['unit'], json['varient_id'], json['qty'], json['price'], json['total_mrp'], json['order_cart_id'], json['order_date'], json['varient_image'], json['addon_id'], json['addon_price'], json['addon_name']);
  }

  @override
  String toString() {
    return '{store_order_id: $store_order_id, product_name: $product_name, quantity: $quantity, unit: $unit, varient_id: $varient_id, qty: $qty, price: $price, total_mrp: $total_mrp, order_cart_id: $order_cart_id, order_date: $order_date, varient_image: $varient_image, addon_id: $addon_id, addon_price: $addon_price, addon_name: $addon_name}';
  }


}