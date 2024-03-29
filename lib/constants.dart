enum AlertAction {
  cancel,
  discard,
  disagree,
  agree,
}

const host = 'https://surveyzulu.com/';
// const host = 'http://127.0.0.1:8000/';

const String loginURL = host + "api/clients/applogin";
const String appleLoginURL = host + "api/clients/appapplelogin";
const String facebookLoginURL = host + "api/clients/appfacebooklogin";
const String googleLoginURL = host + "api/clients/appgooglelogin";
const String registerURL = host + "api/clients/appregister";
const String getCategoriesURL = host + "api/survey-categories";
const String getClientURL = host + "api/appclients/";
const String updateClientURL = host + "api/appclients/";
const String updateSubscriptionURL = host + "api/appupdatesubscription/";
const String getSurveysURL = host + "api/appClientSurveys/";
const String postSurveyURL = host + "api/appsurveys";
const String getSingleSurveyURL = host + "api/appsurveys/";
const String closeSurveyURL = host + "api/appsurveys/close/";
const String openSurveyURL = host + "api/appsurveys/open/";
const String updateSurveyURL = host + "api/appsurveys/";
const String updateSurveyIncentiveURL = host + "api/appsurveys/incentive/";
const String addUserURL = host + "api/appsurveys/user/";
const String updateUserURL = host + "api/appsurveys/user/";
const String deleteUserURL = host + "api/appsurveys/user/d/";
const String getUsersURL = host + "api/appsurveys/user/";
const String getQuestionTypesURL = host + "api/questionTypes";
const String uploadLogoURL = host + "api/appupload/logo/";
const String uploadQuestionPictureURL = host + "api/appupload/picture/";

// Admods Ids
const String androidAds = 'ca-app-pub-8766159028719488/3266963766';
const String iosAds = 'ca-app-pub-8766159028719488/6887989474';
const String androidId = 'ca-app-pub-8766159028719488~2145453783';
const String iosId = 'ca-app-pub-8766159028719488~8922770650';

const bool devMode = false;
const double textScaleFactor = 1.0;