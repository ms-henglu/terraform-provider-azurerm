
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "tse296nk62tsh1xgsa39v9xswgoljv9fm1r6sttrc"
  token_secret = "ey9dxhdabou4kvhsp3mo9gmsxg0ana7e0neer0itj"
}
