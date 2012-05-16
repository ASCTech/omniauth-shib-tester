Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shibboleth, :uid_field => :employeeNumber
end
