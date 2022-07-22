
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "pgfk2okpn4yxkvjp32a3lexnt8jd2sknsa2h228zo"
  token_secret = "w8xbrolxqzgjnn3bu0s77q1hhas7oru0lik7k4tz0"
}
