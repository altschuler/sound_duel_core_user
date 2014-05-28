// From:
// https://developers.facebook.com/docs/javascript/quickstart/v2.0#advancedsetup

window.fbAsyncInit = function() {
  FB.init({
    appId      : '1485565445007266',
    xfbml      : true,
    version    : 'v2.0'
  });
};

(function(d, s, id){
   var js, fjs = d.getElementsByTagName(s)[0];
   if (d.getElementById(id)) {return;}
   js = d.createElement(s); js.id = id;
   js.src = "//connect.facebook.net/en_US/sdk.js";
   fjs.parentNode.insertBefore(js, fjs);
 }(document, 'script', 'facebook-jssdk'));
