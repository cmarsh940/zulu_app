enum AlertAction {
  cancel,
  discard,
  disagree,
  agree,
}

const host = 'https://surveyzulu.com/';
// const host = 'http://localhost:8000/';

const String loginURL = host + "api/clients/applogin";
const String getCategoriesURL = host + "api/survey-categories";
const String getClientURL = host + "api/appclients/";
const String updateClientURL = host + "api/appclients/";
const String getSurveysURL = host + "api/clientSurveys/";
const String postSurveyURL = host + "api/appsurveys";
const String getSingleSurveyURL = host + "api/appsurveys/";
const String closeSurveyURL = host + "api/appsurveys/close/";
const String openSurveyURL = host + "api/appsurveys/open/";
const String updateSurveyURL = host + "api/appsurveys/";
const String getQuestionTypesURL = host + "api/questionTypes";


const bool devMode = false;
const double textScaleFactor = 1.0;