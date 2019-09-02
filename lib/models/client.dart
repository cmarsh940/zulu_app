class ClientModel {
  String id;
  bool a;
  String paymentDate;
  String registerPlatform;
  bool requestedReset;
  String role;
  String subscriptionId;
  String subscriptionStatus;
  int surveyCount;
  List<String> users;
  bool verified;
  List<Notifications> notifications;
  String subscription;
  List<String> surveys;
  String accountType;
  String firstName;
  String lastName;
  String businessName;
  String email;
  String phone;
  String picture;
  String token;
  String createdAt;
  String updatedAt;
  int iV;
  Address address;

  ClientModel(
      {this.id,
      this.a,
      this.paymentDate,
      this.registerPlatform,
      this.requestedReset,
      this.role,
      this.subscriptionId,
      this.subscriptionStatus,
      this.surveyCount,
      // this.users,
      this.verified,
      this.notifications,
      this.subscription,
      this.surveys,
      this.accountType,
      this.firstName,
      this.lastName,
      this.businessName,
      this.email,
      this.phone,
      this.picture,
      this.token,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.address});

  ClientModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    a = json['a'];
    paymentDate = json['paymentDate'];
    registerPlatform = json['registerPlatform'];
    requestedReset = json['requestedReset'];
    role = json['role'];
    subscriptionId = json['subscriptionId'];
    subscriptionStatus = json['subscriptionStatus'];
    surveyCount = json['surveyCount'];
    // users = json['users'].cast<String>();
    verified = json['verified'];
    if (json['_notifications'] != null) {
      notifications = new List<Notifications>();
      json['_notifications'].forEach((v) {
        notifications.add(new Notifications.fromJson(v));
      });
    }
    subscription = json['_subscription'];
    surveys = json['_surveys'].cast<String>();
    accountType = json['accountType'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    businessName = json['businessName'];
    email = json['email'];
    phone = json['phone'];
    picture = json['picture'];
    token = json['token'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    address = json['_address'] != null
        ? new Address.fromJson(json['_address'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['a'] = this.a;
    data['paymentDate'] = this.paymentDate;
    data['registerPlatform'] = this.registerPlatform;
    data['requestedReset'] = this.requestedReset;
    data['role'] = this.role;
    data['subscriptionId'] = this.subscriptionId;
    data['subscriptionStatus'] = this.subscriptionStatus;
    data['surveyCount'] = this.surveyCount;
    // data['users'] = this.users;
    data['verified'] = this.verified;
    if (this.notifications != null) {
      data['_notifications'] =
          this.notifications.map((v) => v.toJson()).toList();
    }
    data['_subscription'] = this.subscription;
    data['_surveys'] = this.surveys;
    data['accountType'] = this.accountType;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['businessName'] = this.businessName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['picture'] = this.picture;
    data['token'] = this.token;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    if (this.address != null) {
      data['_address'] = this.address.toJson();
    }
    return data;
  }
}


class Address {
  String id;
  String country;
  String address;
  String city;
  String state;
  int postalCode;
  String client;
  String createdAt;
  String updatedAt;
  int iV;

  Address(
      {this.id,
      this.country,
      this.address,
      this.city,
      this.state,
      this.postalCode,
      this.client,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Address.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    country = json['country'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    postalCode = json['postalCode'];
    client = json['_client'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['country'] = this.country;
    data['address'] = this.address;
    data['city'] = this.city;
    data['state'] = this.state;
    data['postalCode'] = this.postalCode;
    data['_client'] = this.client;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Notifications {
  String id;
  bool viewed;
  String status;
  String title;
  String message;
  String client;
  String createdAt;
  String updatedAt;
  int iV;

  Notifications(
      {this.id,
      this.viewed,
      this.status,
      this.title,
      this.message,
      this.client,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Notifications.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    viewed = json['viewed'];
    status = json['status'];
    title = json['title'];
    message = json['message'];
    client = json['_client'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['viewed'] = this.viewed;
    data['status'] = this.status;
    data['title'] = this.title;
    data['message'] = this.message;
    data['_client'] = this.client;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}