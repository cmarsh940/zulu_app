import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:project_z/data/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'consumable_store.dart';

const bool kAutoConsume = true;

const String _kConsumableId = '06';
const List<String> _kProductIds = <String>[
  '001',
  '002',
  '003',
  '004',
  '005',
  '006',
];
const List<Map<String,String>> _kProductNames = [
  {'id':'001', 'name': 'basic'},
  {'id':'002', 'name': 'pro'},
  {'id':'003', 'name': 'elite'},
  {'id':'004', 'name': 'basic annually'},
  {'id':'005', 'name': 'pro annually'},
  {'id':'006', 'name': 'elite annually'},
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
  }

  updateSubscription(Payment data) async {
    String newSubscription;


    _kProductNames.forEach((f) => {
      
      if (data.id == f['id']) {
        newSubscription = f['name']
      }
    });
    if (newSubscription != null) {
      SharedPreferences.getInstance().then((prefs) {  
        prefs.setString("_subscription", newSubscription);
      });
      
      var w = await _clientRepository.updateSubscription(data);
      return w;
    } else {
      print('subscription was null');
    }
  }

  _launchPriceURL() async {
    const url = 'https://surveyzulu.com/app_pricing';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
        child: Text('ERROR: $_queryProductError'),
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
      title: Text((_isAvailable ? 'Connected' : 'Store unavailable') + '.'),
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
    ListTile productHeader = ListTile(
      title: Text('Subscriptions', style: Theme.of(context).textTheme.headline),
      subtitle: Text('** Note: Unless specified as annual, all subscriptions are a 1 month auto renewal basis. If specified as annual the subscription is a 1 year auto renewal. All subscriptions can be canceled at any time.', style:  Theme.of(context).textTheme.caption)
    );
    List<ListTile> productList = <ListTile>[];
    if (_notFoundIds.isNotEmpty) {
      productList.add(ListTile(
        title: Text('[${_notFoundIds.join(", ")}] Error retrieving subscriptions', style: TextStyle(color: ThemeData.light().errorColor)),
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
        title: Text(productDetails.title ?? 'Error'),
        subtitle: Text(productDetails.description ?? ''),
        trailing: (productDetails.title != null && subscription != productDetails.title.toLowerCase()) ? FlatButton(
            child: Text(productDetails.price ?? ''),
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
            child: Icon(Icons.check),
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
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                child: Text('View pricing details', style: TextStyle(color: Colors.green[800]),), 
                onPressed: () {
                  _launchPriceURL();
                },
              ),
            ]
          ),
          Divider()
        ] + productList
      )
    );
  }

  Future<void> consume(String id) async {
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

    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    print('NEED TO HANDLE INVALID PURCHASE');
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  static ListTile buildListCard(ListTile innerTile) =>
      ListTile(title: Card(child: innerTile));

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print("ERROR PURCHASING: ${purchaseDetails.error.source}");
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            Payment temp = new Payment(purchaseDetails.productID, purchaseDetails.purchaseID);
            bool done = await updateSubscription(temp);
            if (done != null && done) {
              deliverProduct(purchaseDetails);
            } else {
            _handleInvalidPurchase(purchaseDetails);
          }
          } else {
            _handleInvalidPurchase(purchaseDetails);
          }
        }
        if (Platform.isIOS) {
          InAppPurchaseConnection.instance.completePurchase(purchaseDetails);
        } else if (Platform.isAndroid) {
          if (!kAutoConsume && purchaseDetails.productID == _kConsumableId) {
            InAppPurchaseConnection.instance.consumePurchase(purchaseDetails);
          }
        }
      }
    });
  }
}