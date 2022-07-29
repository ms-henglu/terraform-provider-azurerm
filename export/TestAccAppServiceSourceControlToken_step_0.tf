
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "ufvxnw07eh8ku9m3abszcgemrj2wbf2hvxhh9d9ms"
  token_secret = "ntqp3ml7ki8ndhovlhhkb7epqrralsiwrp07okmjo"
}
