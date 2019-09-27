import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_z/auth/authentication.dart';
import 'package:project_z/data/repositories.dart';
import 'package:project_z/models/client.dart';


import 'profile_bloc/profile.dart';

typedef OnSaveCallback = Function(ClientModel client);

class EditProfileForm extends StatefulWidget {
  final ClientModel client;
  final OnSaveCallback onSave;
  final ClientRepository _clientRepository;

  EditProfileForm({
    Key key,
    this.client, @required this.onSave, @required ClientRepository clientRepository,
  }) : assert(clientRepository != null),
        _clientRepository = clientRepository, super(key: key);

  @override
  _EditProfileFormState createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  ProfileBloc _profileBloc;
  ClientModel get client => widget.client;
  ClientRepository get _clientRepository => widget._clientRepository;
  
  bool rebuild;  


  List<Map<String, String>> states = [
    {
        'name': 'Alabama',
        'abbreviation': 'AL'
    },
    {
        'name': 'Alaska',
        'abbreviation': 'AK'
    },
    {
        'name': 'American Samoa',
        'abbreviation': 'AS'
    },
    {
        'name': 'Arizona',
        'abbreviation': 'AZ'
    },
    {
        'name': 'Arkansas',
        'abbreviation': 'AR'
    },
    {
        'name': 'California',
        'abbreviation': 'CA'
    },
    {
        'name': 'Colorado',
        'abbreviation': 'CO'
    },
    {
        'name': 'Connecticut',
        'abbreviation': 'CT'
    },
    {
        'name': 'Delaware',
        'abbreviation': 'DE'
    },
    {
        'name': 'District Of Columbia',
        'abbreviation': 'DC'
    },
    {
        'name': 'Federated States Of Micronesia',
        'abbreviation': 'FM'
    },
    {
        'name': 'Florida',
        'abbreviation': 'FL'
    },
    {
        'name': 'Georgia',
        'abbreviation': 'GA'
    },
    {
        'name': 'Guam',
        'abbreviation': 'GU'
    },
    {
        'name': 'Hawaii',
        'abbreviation': 'HI'
    },
    {
        'name': 'Idaho',
        'abbreviation': 'ID'
    },
    {
        'name': 'Illinois',
        'abbreviation': 'IL'
    },
    {
        'name': 'Indiana',
        'abbreviation': 'IN'
    },
    {
        'name': 'Iowa',
        'abbreviation': 'IA'
    },
    {
        'name': 'Kansas',
        'abbreviation': 'KS'
    },
    {
        'name': 'Kentucky',
        'abbreviation': 'KY'
    },
    {
        'name': 'Louisiana',
        'abbreviation': 'LA'
    },
    {
        'name': 'Maine',
        'abbreviation': 'ME'
    },
    {
        'name': 'Marshall Islands',
        'abbreviation': 'MH'
    },
    {
        'name': 'Maryland',
        'abbreviation': 'MD'
    },
    {
        'name': 'Massachusetts',
        'abbreviation': 'MA'
    },
    {
        'name': 'Michigan',
        'abbreviation': 'MI'
    },
    {
        'name': 'Minnesota',
        'abbreviation': 'MN'
    },
    {
        'name': 'Mississippi',
        'abbreviation': 'MS'
    },
    {
        'name': 'Missouri',
        'abbreviation': 'MO'
    },
    {
        'name': 'Montana',
        'abbreviation': 'MT'
    },
    {
        'name': 'Nebraska',
        'abbreviation': 'NE'
    },
    {
        'name': 'Nevada',
        'abbreviation': 'NV'
    },
    {
        'name': 'New Hampshire',
        'abbreviation': 'NH'
    },
    {
        'name': 'New Jersey',
        'abbreviation': 'NJ'
    },
    {
        'name': 'New Mexico',
        'abbreviation': 'NM'
    },
    {
        'name': 'New York',
        'abbreviation': 'NY'
    },
    {
        'name': 'North Carolina',
        'abbreviation': 'NC'
    },
    {
        'name': 'North Dakota',
        'abbreviation': 'ND'
    },
    {
        'name': 'Northern Mariana Islands',
        'abbreviation': 'MP'
    },
    {
        'name': 'Ohio',
        'abbreviation': 'OH'
    },
    {
        'name': 'Oklahoma',
        'abbreviation': 'OK'
    },
    {
        'name': 'Oregon',
        'abbreviation': 'OR'
    },
    {
        'name': 'Palau',
        'abbreviation': 'PW'
    },
    {
        'name': 'Pennsylvania',
        'abbreviation': 'PA'
    },
    {
        'name': 'Puerto Rico',
        'abbreviation': 'PR'
    },
    {
        'name': 'Rhode Island',
        'abbreviation': 'RI'
    },
    {
        'name': 'South Carolina',
        'abbreviation': 'SC'
    },
    {
        'name': 'South Dakota',
        'abbreviation': 'SD'
    },
    {
        'name': 'Tennessee',
        'abbreviation': 'TN'
    },
    {
        'name': 'Texas',
        'abbreviation': 'TX'
    },
    {
        'name': 'Utah',
        'abbreviation': 'UT'
    },
    {
        'name': 'Vermont',
        'abbreviation': 'VT'
    },
    {
        'name': 'Virgin Islands',
        'abbreviation': 'VI'
    },
    {
        'name': 'Virginia',
        'abbreviation': 'VA'
    },
    {
        'name': 'Washington',
        'abbreviation': 'WA'
    },
    {
        'name': 'West Virginia',
        'abbreviation': 'WV'
    },
    {
        'name': 'Wisconsin',
        'abbreviation': 'WI'
    },
    {
        'name': 'Wyoming',
        'abbreviation': 'WY'
    }
];
  

  @override
  void initState() {
    super.initState();
     _profileBloc = BlocProvider.of<ProfileBloc>(context);
     rebuild = false;
  }

  @override
  void dispose() { 
    _profileBloc.dispose();
    super.dispose();
  }
    
  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _profileBloc,
      listener: (BuildContext context, ProfileState state) {
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Failure'), Icon(Icons.error)],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Submitting...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          BlocProvider.of<AuthenticationBloc>(context).dispatch(LoggedIn());
        }
      },
      child: BlocBuilder(
        bloc: _profileBloc,
        builder: (BuildContext context, ProfileState state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Edit Profile',
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    FormBuilder(
                      key: _fbKey,
                      autovalidate: true,
                      child: Column(
                        children: <Widget>[
                          FormBuilderTextField(
                            attribute: "firstName",
                            decoration: InputDecoration(labelText: "First Name"),
                            initialValue: client?.firstName,
                            onChanged: (value) => client?.firstName = value,
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                          ),
                          FormBuilderTextField(
                            attribute: "lastName",
                            decoration: InputDecoration(labelText: "Last Name"),
                            initialValue: client?.lastName,
                            onChanged: (value) => client?.lastName = value,
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                          ),
                          FormBuilderTextField(
                            attribute: "businessName",
                            decoration: InputDecoration(labelText: "Business Name"),
                            initialValue: client?.businessName,
                            onChanged: (value) => client?.businessName = value,
                          ),
                          FormBuilderTextField(
                            attribute: "email",
                            decoration: InputDecoration(labelText: "Email"),
                            initialValue: client?.email,
                            onChanged: (value) => client?.email = value,
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                          ),
                          FormBuilderTextField(
                            attribute: "phone",
                            decoration: InputDecoration(labelText: "Phone Number"),
                            initialValue: client?.phone,
                            onChanged: (value) => client?.phone = value,
                          ),
                          FormBuilderTextField(
                            attribute: "address",
                            decoration: InputDecoration(labelText: "Address"),
                            initialValue: client?.address?.address,
                            onChanged: (value) => client?.address?.address = value,
                          ),
                          FormBuilderTextField(
                            attribute: "city",
                            decoration: InputDecoration(labelText: "City"),
                            initialValue: client?.address?.city,
                            onChanged: (value) => client?.address?.city = value,
                          ),
                          FormBuilderDropdown(
                            attribute: "state",
                            decoration: InputDecoration(labelText: "State"),
                            initialValue: client?.address?.state,
                            // validators: [
                            //   FormBuilderValidators.required(),
                            // ],
                            hint: Text('Select State'),
                            items: states.map((Map q) => DropdownMenuItem(
                              value: q['abbreviation'],
                              child: Text('${q['name']}'),
                            )).toList(),
                            onChanged: (value) => client?.address?.state = value,
                          ),
                          FormBuilderTextField(
                            attribute: "postalCode",
                            decoration: InputDecoration(labelText: "Postal Code"),
                            initialValue: (client?.address?.postalCode != null) ? client?.address?.postalCode.toString() : '',
                            onChanged: (value) => client?.address?.postalCode = value.toInt(),
                          ),
                          
                          
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: MaterialButton(
                                  color: Theme.of(context).accentColor,
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    _fbKey.currentState.save();
                                    if (_fbKey.currentState.validate()) {
                                      _submitForm(client);
                                      // _submitForm(_fbKey.currentState.value);
                                    } else {
                                      print(_fbKey.currentState.value);
                                      print("validation failed");
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: MaterialButton(
                                  color: Theme.of(context).accentColor,
                                  child: Text(
                                    "Reset",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    _fbKey.currentState.reset();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      )
    );
  }

  _submitForm(ClientModel client) async {
    _fbKey.currentState.save();
    widget.onSave(client);
    _profileBloc.dispatch(
      SubmissionProfileButtonPressed(
        client: client
      ),
    );
  }
}