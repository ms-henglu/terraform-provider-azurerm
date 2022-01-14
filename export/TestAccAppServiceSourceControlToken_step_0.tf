
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "i7zhljbiciewkbx4fl43rabq3clx2totahl0m4h9f"
  token_secret = "o174h3ixa7pmfz29wpxwhwa2y000hdmambp6jm9b1"
}
