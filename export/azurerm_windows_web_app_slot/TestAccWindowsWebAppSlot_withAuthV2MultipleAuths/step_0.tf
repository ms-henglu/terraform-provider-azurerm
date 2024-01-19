
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024436555949"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-WAS-240119024436555949"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"
}

resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-240119024436555949"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}
}


resource "azurerm_windows_web_app_slot" "test" {
  name           = "acctestWAS-240119024436555949"
  app_service_id = azurerm_windows_web_app.test.id

  site_config {}

  app_settings = {
    "APPLE_PROVIDER_AUTHENTICATION_SECRET"     = "902D17F6-FD6B-4E44-BABB-58E788DCD907"
    "FACEBOOK_PROVIDER_AUTHENTICATION_SECRET"  = "902D17F6-FD6B-4E44-BABB-58E788DCD907"
    "GITHUB_PROVIDER_AUTHENTICATION_SECRET"    = "902D17F6-FD6B-4E44-BABB-58E788DCD907"
    "GOOGLE_PROVIDER_AUTHENTICATION_SECRET"    = "902D17F6-FD6B-4E44-BABB-58E788DCD907"
    "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET" = "902D17F6-FD6B-4E44-BABB-58E788DCD907"
    "TWITTER_PROVIDER_AUTHENTICATION_SECRET"   = "902D17F6-FD6B-4E44-BABB-58E788DCD907"
  }

  auth_settings_v2 {
    auth_enabled           = true
    unauthenticated_action = "RedirectToLoginPage"

    apple_v2 {
      client_id                  = "testAppleID"
      client_secret_setting_name = "APPLE_PROVIDER_AUTHENTICATION_SECRET"
    }

    facebook_v2 {
      app_id                  = "testFacebookID"
      app_secret_setting_name = "FACEBOOK_PROVIDER_AUTHENTICATION_SECRET"
    }

    github_v2 {
      client_id                  = "testGithubID"
      client_secret_setting_name = "GITHUB_PROVIDER_AUTHENTICATION_SECRET"
    }

    google_v2 {
      client_id                  = "testGoogleID"
      client_secret_setting_name = "GOOGLE_PROVIDER_AUTHENTICATION_SECRET"
    }

    microsoft_v2 {
      client_id                  = "testMSFTID"
      client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
    }

    twitter_v2 {
      consumer_key                 = "testTwitterKey"
      consumer_secret_setting_name = "TWITTER_PROVIDER_AUTHENTICATION_SECRET"
    }

    login {}
  }
}
