// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, no_logic_in_create_state, avoid_print, use_build_context_synchronously, unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:preggo/NavBar.dart';
import 'package:preggo/login_screen.dart';
import 'package:preggo/start_Journey.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';
import 'package:email_validator/email_validator.dart';
import 'package:preggo/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SplashScreen.dart';
import 'package:preggo/screens/post_community.dart';

class SignUp extends StatefulWidget {
  //const SignUp({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormFieldState> _usernameKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _emailKey = GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> _phoneKey = GlobalKey<FormFieldState>();
  final CollectionReference ref =
      FirebaseFirestore.instance.collection('users');
  bool usernameTaken = false;
  bool emailTaken = false;
  bool phoneTaken = false;
  bool hidePassword = true;
  FirebaseAuth auth = FirebaseAuth.instance;
  late UserCredential userCredential;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//sign up UI

    final validCharacters = RegExp(r'^[a-zA-Z0-9]+$'); //alphamumerical

    Future<bool> uniqueUsername(String username) async {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .get();
      return query.docs.isNotEmpty;
    }

    Future<bool> uniqueEmail(String email) async {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .get();
      return query.docs.isNotEmpty;
    }

    Future<bool> uniquePhone(String phone) async {
      print(phone);
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();
      if (query.docs.isNotEmpty) {
        print("phone is taken");
      }
      return query.docs.isNotEmpty;
    }

    String phoneNo = '';
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backGroundPink,
      // backgroundColor: whiteColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              //const SizedBox(height: 40.0),
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  "Get Started",
                  style: TextStyle(
                    color: Color(0xFFD77D7C),
                    fontSize: 38,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    height: 1.30,
                    letterSpacing: -0.28,
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 50,
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 22.0,
                      right: 22,
                      top: 5.0,
                      bottom: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(80.0),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 40.0),
                          Text("Create a Preggo account",
                              style: TextStyle(
                                fontSize: 23.0,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 15.0),
                          /*const SizedBox(height: 40.0),
                            Text("Welcome back!",
                                style: TextStyle(
                                  fontSize: 23.0,
                                  fontWeight: FontWeight.w600,
                                )),
                                */
                          //  const SizedBox(height: 50.0),
                          Container(
                            height: 85,
                            constraints: BoxConstraints(maxHeight: 100),
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              maxLength: 25,
                              controller: _usernameController,
                              key: _usernameKey,
                              validator: (value) {
                                /*
                                        username validations:
                                        --FRONT END--
                                        1- not empty
                                        2- no spaces
                                        3- no special characters (only letters and digits)
                                        --BACK END--
                                        4- unique
                                        */

                                if (value!.trim().isEmpty == true) {
                                  return "This field cannot be empty.";
                                } else if (!validCharacters.hasMatch(value)) {
                                  return "Only alphanumerical values allowed."; //maybe change error message
                                } else if (usernameTaken) {
                                  return 'Username is already taken!';
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Username",
                                helperText: '',
                                labelStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: grayColor,
                                ),
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: textFieldBackgroundColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                  borderSide:
                                      BorderSide(color: textFieldBorderColor),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                  borderSide: BorderSide(color: darkGrayColor),
                                ),
                              ),
                            ),
                          ),

                          // const SizedBox(height: 22.0),
                          Container(
                            height: 85,
                            constraints: BoxConstraints(maxHeight: 100),
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              maxLength: 50,
                              controller: _emailController,
                              key: _emailKey,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return "This field cannot be empty.";
                                } else if (!EmailValidator.validate(value)) {
                                  return "Incorrect email format.";
                                  // var username =
                                  //     value.substring(0, value.indexOf('@'));
                                  // var domain = value.substring(
                                  //     value.indexOf('@') + 1,
                                  //     value.indexOf('.'));
                                  // var end =
                                  //     value.substring(value.indexOf('.') + 1);
                                  // bool specialChar = false;
                                  // for(int i = 0; i < username.length; i++){
                                  //   if(!isAlphanumeric(username[i])){
                                  //     if()
                                  //   }
                                  // }
                                } else if (emailTaken) {
                                  return 'Email is already taken!';
                                  // } else if (EmailValidator.validate(value)) {
                                  //   var specialchar =
                                  //       RegExp(r'[!#$%^&*(),?":{}|<>/\+=-]');
                                  //   if (specialchar.hasMatch(value)) {
                                  //     return "Incorrect email format.";
                                  //   }
                                  //   var dot = '.'.allMatches(value).length;
                                  //   if (dot > 1) {
                                  //     return "Incorrect email format.";
                                  //   }
                                } else {
                                  var specialchar =
                                      RegExp(r'[!#$%^&*(),?":{}|<>/\+=-]');
                                  if (specialchar.hasMatch(value)) {
                                    return "Incorrect email format.";
                                  }
                                  // var dot = '.'.allMatches(value).length;
                                  // if (dot > 1) {
                                  //   return "Incorrect email format.";
                                  // } //could be removed in the future if we can fix firebase invalid-email exception
                                  if (value
                                          .substring(value.indexOf('.') + 1)
                                          .length <
                                      2) {
                                    return "Incorrect email format."; //for example abc@gmail.C (only 1 character after the dot) is invalid because firebase will throw invalid-email exception
                                  }
                                  return null;
                                }
                              },
                              /*
                                        email validations:
                                        --FRONT END--
                                        1- format: xxx@xxx.xxx
                                        2- only allowed characters of email
                                        3- only 1 @
                                        4- not empty
                                        --BACK END--
                                        5- unique
                                        */
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                helperText:
                                    'Email format should be: firstname@example.com',
                                hintText: "Email",
                                labelStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: grayColor,
                                ),
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: textFieldBackgroundColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                  borderSide:
                                      BorderSide(color: textFieldBorderColor),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                  borderSide: BorderSide(color: darkGrayColor),
                                ),
                              ),
                            ),
                          ),

                          Container(
                            height: 85,
                            constraints: BoxConstraints(maxHeight: 100),
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              maxLength: 10,
                              controller: _phoneController,
                              key: _phoneKey,
                              onChanged: (p) => phoneNo = p.toString(),
                              /*
                                        phone number validations
                                        --FRONT END--
                                        1- 10 digits
                                        2- digits only
                                        --BACK END--
                                        3- unique (???)
                                        */
                              validator: (phone) {
                                // if (phone.toString().isEmpty) {
                                //   return 'This field cannot be empty.';
                                // }
                                bool hasLetter = false;
                                int i = 0;
                                while (i < phone!.toString().length) {
                                  if (!isNumeric(phone.toString()[i])) {
                                    hasLetter = true;
                                  }
                                  i++;
                                }
                                if (hasLetter) {
                                  return 'Phone number must contain only digits.';
                                } else if (phone.toString().length != 0 &&
                                    phone.toString().length != 10) {
                                  return 'Phone number must be 10 digits.';
                                  // } else if (phoneTaken) {
                                  //
                                  // return 'Phone number is already taken!';
                                } else if (phone.toString().length == 10 &&
                                    phone.toString().substring(0, 2) != '05') {
                                  return 'Incorrect phone number format.';
                                } else {
                                  return null;
                                }
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                helperText:
                                    'Phone number format should be: 05xxxxxxxx',
                                hintText: "Phone number (optional)",
                                labelStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: grayColor,
                                ),
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: textFieldBackgroundColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                  borderSide:
                                      BorderSide(color: textFieldBorderColor),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                  borderSide: BorderSide(color: darkGrayColor),
                                ),
                              ),
                            ),
                          ),

                          Container(
                            // padding: EdgeInsets.only(bottom: 10),
                            height: 95,
                            constraints: BoxConstraints(maxHeight: 95),
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: _passwordController,
                              maxLength: 50,

                              /*
                                      password validations
                                      1- 8 digits or more
                                      2- at least one capital
                                      3- at least one number
                                      */

                              decoration: InputDecoration(
                                errorMaxLines: 2,
                                helperText:
                                    'Password should be at least 8 characters long',
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Colors.grey,
                                ),
                                hintText: 'Password',
                                labelStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: grayColor,
                                ),
                                filled: true,
                                fillColor: textFieldBackgroundColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                  borderSide:
                                      BorderSide(color: textFieldBorderColor),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                  borderSide: BorderSide(color: darkGrayColor),
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      hidePassword = !hidePassword;
                                    });
                                  },
                                  child: hidePassword
                                      ? const Icon(
                                          Icons.visibility_off,
                                          color: Colors.grey,
                                        )
                                      : const Icon(
                                          Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),
                              obscureText: hidePassword ? true : false,
                              autocorrect: false,
                              validator: (pass) {
                                if (pass!.trim().isEmpty == true) {
                                  return "This field cannot be empty.";
                                } else if (pass.length < 8) {
                                  return "Password must be at least 8 characters.";
                                } else {
                                  bool hasDigit = false;
                                  bool hasUppercase = false;
                                  int i = 0;
                                  while (i < pass.length) {
                                    if (isNumeric(pass[i])) {
                                      hasDigit = true;
                                    } else if (isUppercase(pass[i])) {
                                      hasUppercase = true;
                                    }
                                    i++;
                                  } //end while
                                  if (hasDigit == false ||
                                      hasUppercase == false) {
                                    return "Password must contain at least one uppercase \nletter and one digit.";
                                  }
                                } //end else
                                return null;
                              },
                            ),
                          ),

                          //const SizedBox(height: 45.0),
                          MaterialButton(
                            color: darkBlackColor,
                            minWidth: double.infinity,
                            height: 48,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            onPressed: () async {
                              final FormState form = _formKey.currentState!;
                              usernameTaken = await uniqueUsername(
                                  _usernameKey.currentState!.value.trim());
                              setState(() {});
                              emailTaken = await uniqueEmail(
                                  _emailKey.currentState!.value.trim());
                              /*setState(() {});
                                phoneTaken = await uniquePhone(
                                    _phoneKey.currentState?.value);*/
                              form.validate();

                              setState(() {});
                              if (_formKey.currentState!.validate()) {
                                try {
                                  userCredential = await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text);
                                } catch (error) {
                                  print(
                                      'exception caught in registration try/catch');
                                  return null;
                                }
                                _formKey.currentState?.save();
                                if (_phoneController.text.trim().isEmpty) {
                                  Map<String, String> dataToSave = {
                                    'username': _usernameController.text
                                        .toLowerCase()
                                        .trim(),
                                    'email': _emailController.text
                                        .toLowerCase()
                                        .trim(),
                                  };
                                  FirebaseFirestore.instance
                                      .collection('users/')
                                      .doc(userCredential.user!.uid)
                                      .set(dataToSave);
                                  print(
                                      'Registration successful with NO PHONE');
                                } else {
                                  Map<String, String> dataToSave = {
                                    'username': _usernameController.text
                                        .toLowerCase()
                                        .trim(),
                                    'email': _emailController.text
                                        .toLowerCase()
                                        .trim(),
                                    //'password': _passwordController.text,
                                    'phone': _phoneController.text.trim(),
                                    'admin': '0'
                                  };
                                  FirebaseFirestore.instance
                                      .collection('users/')
                                      .doc(userCredential.user!.uid)
                                      .set(dataToSave);
                                  print('Registration successful WITH PHONE');
                                }
                                // POST COMMUNITY - SAVE USERNAME LOCAL
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString(
                                  "username",
                                  _usernameController.text.trim(),
                                );
                                // End
                                /* Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => startJourney())); */
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => startJourney()));
                              }
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: whiteColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                      color: blackColor,
                                    ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                    builder: (context) {
                                      return const LoginScreen();
                                    },
                                  ), (route) => false);
                                },
                                child: Text(
                                  'Sign In!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: pinkColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                ),
                              )
                            ],
                          ),
                          Container(
                            height: 100,
                          ),
                          Container(
                              height:
                                  MediaQuery.of(context).viewInsets.bottom + 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
