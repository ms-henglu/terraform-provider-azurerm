
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "w8t96sulyrvmlupdp9pojphki3lwe2xnd2k8wdcv0"
  token_secret = "amgu9n8g78v004enph3dzf7sktmyqbe1omsvx7012"
}
