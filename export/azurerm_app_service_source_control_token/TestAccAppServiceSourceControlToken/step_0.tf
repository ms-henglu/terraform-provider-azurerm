
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "7bcbrb3nzdhx4mvc2ufb3w29ii0gjyyyo8eegpsyn"
  token_secret = "wbimvik9keqzt7m0tq7cvkhckc71z0dokwzcgj8s7"
}
