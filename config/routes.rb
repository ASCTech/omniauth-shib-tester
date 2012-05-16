OmniauthShibTester::Application.routes.draw do

  get '/auth/shibboleth/callback' => 'env#show'

  root :to => 'env#show'

end
