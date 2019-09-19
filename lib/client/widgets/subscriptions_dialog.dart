import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:project_z/data/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'consumable_store.dart';

const bool kAutoConsume = true;

const String _kConsumableId = '06';
const List<String> _kProductIds = <String>[
  '01',
  '02',
  '03',
  '04',
  '05',
  '06',
];
const List<Map<String,String>> _kProductNames = [
  {'id':'01', 'name': 'basic'},
  {'id':'02', 'name': 'pro'},
  {'id':'03', 'name': 'elite'},
  {'id':'04', 'name': 'basic annually'},
  {'id':'05', 'name': 'pro annually'},
  {'id':'06', 'name': 'elite annually'},
];

class SubscriptionDialog extends StatefulWidget {
  final String id;
  final ClientRepository _clientRepository;

  const SubscriptionDialog({Key key, this.id, @required ClientRepository clientRepository,
  }) : assert(clientRepository != null),
        _clientRepository = clientRepository, super(key: key);

  @override
  _SubscriptionDialogState createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<SubscriptionDialog> with WidgetsBindingObserver {
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  List<String> _consumables = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError;
  String get id => widget.id;
  ClientRepository get _clientRepository => widget._clientRepository;
  dynamic subscription;

  @override
  void initState() {
    getSubscription();

    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      print('_subscription is done, canceling now');
      _subscription.cancel();
    }, onError: (error) {
      print('ERROR: $error');
    });
    initStoreInfo();
    super.initState();
  }

  getSubscription() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    subscription = pref.getString("_subscription").toLowerCase() ?? '';
    print('subscription is: $subscription');
  }
  updateSubscription(Payment data) async {
    print('update id is: $id');
    String newSubscription;


    _kProductNames.forEach((f) => {
      
      if (data.id == f['id']) {
        newSubscription = f['name']
      }
    });
    print('new subscription is: $newSubscription');
    if (newSubscription != null) {
      SharedPreferences.getInstance().then((prefs) {  
        prefs.setString("_subscription", newSubscription);
      });
      
      print('subscription is: $subscription');
      var w = await _clientRepository.updateSubscription(data);
      print('dialog data is: $w');
    } else {
      print('subscription was null');
    }
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _notFoundIds = [];
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    ProductDetailsResponse productDetailResponse = await _connection.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final QueryPurchaseDetailsResponse purchaseResponse =
        await _connection.queryPastPurchases();
    if (purchaseResponse.error != null) {
      // handle query past purchase error..
    }
    final List<PurchaseDetails> verifiedPurchases = [];
    for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
      if (await _verifyPurchase(purchase)) {
        verifiedPurchases.add(purchase);
      }
    }
    List<String> consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = verifiedPurchases;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stack = [];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: [
            _buildConnectionCheckTile(),
            _buildProductList(),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_queryProductError),
      ));
    }
    if (_purchasePending) {
      stack.add(
        Stack(
          children: [
            new Opacity(
              opacity: 0.3,
              child: const ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            new Center(
              child: new CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop()
        ),
        title: Text('Manange Subscription'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
      ),
      body: Stack(
        children: stack,
      ),
    );
  }

  Card _buildConnectionCheckTile() {
    if (_loading) {
      return Card(child: ListTile(title: const Text('Trying to connect...')));
    }
    final Widget storeHeader = ListTile(
      leading: Icon(_isAvailable ? Icons.check : Icons.block, color: _isAvailable ? Colors.green : ThemeData.light().errorColor),
      title: Text('The store is ' + (_isAvailable ? 'available' : 'unavailable') + '.'),
    );
    final List<Widget> children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll([
        Divider(),
        ListTile(
          title: Text('Not connected', style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text('Unable to connect to the payments processor. Please try again later'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Card _buildProductList() {
    if (_loading) {
      return Card(
        child: (ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Fetching subscriptions...')
        ))
      );
    }
    if (!_isAvailable) {
      return Card();
    }
    ListTile productHeader = ListTile(title: Text('Subscriptions', style: Theme.of(context).textTheme.headline));
    List<ListTile> productList = <ListTile>[];
    if (_notFoundIds.isNotEmpty) {
      productList.add(ListTile(
        title: Text('[${_notFoundIds.join(", ")}] not found', style: TextStyle(color: ThemeData.light().errorColor)),
        subtitle: Text('There was a Error ')
      ));
    }


    // LIST OF SUBSCRIPTIONS
    Map<String, PurchaseDetails> purchases = Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
      if (Platform.isIOS) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));


    productList.addAll(_products.map((ProductDetails productDetails) {
      PurchaseDetails previousPurchase = purchases[productDetails.id];
      return ListTile(
        title: Text(productDetails.title),
        subtitle: Text(productDetails.description),
        trailing: previousPurchase != null
          ? Icon(Icons.check)
          : (subscription != productDetails.title.toLowerCase()) ? FlatButton(
            child: Text(productDetails.price),
            color: Colors.green[800],
            textColor: Colors.white,
            onPressed: () {
              PurchaseParam purchaseParam = PurchaseParam(
                  productDetails: productDetails,
                  applicationUserName: id,
                  sandboxTesting: true);
              if (productDetails.id == _kConsumableId) {
                _connection.buyConsumable(
                    purchaseParam: purchaseParam,
                    autoConsume: kAutoConsume || Platform.isIOS);
              } else {
                _connection.buyNonConsumable(purchaseParam: purchaseParam);
              }
            },
          ) : FlatButton(
            child: Text(productDetails.price),
            color: Colors.grey,
            textColor: Colors.white,
            onPressed: () {
              print('this is your current subscription');
            },
          ),
      );
    }));

    return Card(
      child: Column(
        children: <Widget>[
          productHeader, 
          Divider()
        ] + productList
      )
    );
  }

  Future<void> consume(String id) async {
    print('*** hit consume with id: $id');
    await ConsumableStore.consume(id);
    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _consumables = consumables;
    });
  }

  void showPendingUI() {
    print('PENDING...');
    setState(() {
      _purchasePending = true;
    });
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    print('PRODUCT ID PURCHASED: ${purchaseDetails.productID.toString()}');
    // IMPORTANT!! Always verify a purchase purchase details before delivering the product.
    if (purchaseDetails.productID == _kConsumableId) {
      await ConsumableStore.save(purchaseDetails.purchaseID);
      List<String> consumables = await ConsumableStore.load();
      setState(() {
        _purchasePending = false;
        _consumables = consumables;
      });
    } else {
      setState(() {
        _purchases.add(purchaseDetails);
        _purchasePending = false;
      });
    }
    Navigator.of(context).pop();
  }

  void handleError(IAPError error) {
    print('*** ERROR CODE: ${error.code}');
    print('*** ERROR DETAILS: ${error.details}');
    print('*** ERROR MESSAGE: ${error.message}');
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {

    print('Verify Product ID ${purchaseDetails.productID}');
    print('Verify Purchase ID ${purchaseDetails.purchaseID}');
    print('Verify Purchase DATA SOURCE ${purchaseDetails.verificationData.source}');

    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  static ListTile buildListCard(ListTile innerTile) =>
      ListTile(title: Card(child: innerTile));

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    print('*** Hit purchase update');
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print('*** Purchase Pending');
        showPendingUI();
      } else {
        print('Purchase status : ${purchaseDetails.status}');
        if (purchaseDetails.status == PurchaseStatus.error) {
          print("ERROR PURCHASING: ${purchaseDetails.error.source}");
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          print('*** Purchase Purchased ${purchaseDetails.productID}');
          bool valid = await _verifyPurchase(purchaseDetails);
          print("Verify Valid Purchase: $valid");
          if (valid) {
            Payment temp = new Payment(purchaseDetails.productID, purchaseDetails.purchaseID);
            bool done = await updateSubscription(temp);
            if (done) {
              deliverProduct(purchaseDetails);
            } else {
            _handleInvalidPurchase(purchaseDetails);
          }
          } else {
            _handleInvalidPurchase(purchaseDetails);
          }
        }
        if (Platform.isIOS) {
          print('*** Platform is IOS');
          InAppPurchaseConnection.instance.completePurchase(purchaseDetails);
        } else if (Platform.isAndroid) {
          print('*** Platform is ANDROID');
          if (!kAutoConsume && purchaseDetails.productID == _kConsumableId) {
            InAppPurchaseConnection.instance.consumePurchase(purchaseDetails);
          }
        }
      }
    });
  }
}