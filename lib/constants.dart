enum AlertAction {
  cancel,
  discard,
  disagree,
  agree,
}

//  const host = 'https://surveyzulu.com/';
const host = 'http://127.0.0.1:8000/';

const String loginURL = host + "api/clients/applogin";
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


const bool devMode = false;
const double textScaleFactor = 1.0;