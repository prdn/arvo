::  Test url +https://graph.facebook.com/v2.5/me
::
::::  /hoon/facebook/com/sec
  ::
/+    oauth2
::
::::
  ::
|%
++  dialog-url    'https://www.facebook.com/dialog/oauth?response_type=code'
++  exchange-url  'https://graph.facebook.com/v2.3/oauth/access_token'
--
::
::::
  ::
|_  {bal/(bale keys:oauth2) access-token/token:oauth2}
::  aut is a "standard oauth2" core, which implements the 
::  most common handling of oauth2 semantics. see lib/oauth2 for more details.
++  aut
  %+  ~(standard oauth2 bal access-token)  .
  |=(access-token/token:oauth2 +>(access-token access-token))
::
++  out
  %^  out-add-query-param:aut  'access_token'
    scope=~['user_about_me' 'user_posts']
  dialog-url
::
++  in  (in-code-to-token:aut exchange-url)
::
++  bak
  |=  a/httr  ^-  core-move:aut
  ?:  (bad-response:aut p.a)  
    [%give a]  :: [%redo ~]  ::  handle 4xx?
  =+  `{access-token/@t expires-in/@u}`(grab-expiring-token:aut a)
  ?.  (lth expires-in ^~((div ~d7 ~s1)))  ::  short-lived token
    [[%redo ~] ..bak(access-token access-token)]
  :-  %send
  %^  request-token:aut  exchange-url
    grant-type='fb_exchange_token'
  [key='fb_exchange_token' value=access-token]~
--
