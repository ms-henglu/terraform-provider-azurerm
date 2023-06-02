
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "8c8usryncritwubszwwn7g4gvastej3xszdwfgu4p"
  token_secret = "44k6evhg4yzy0j6helub6b23dakjbk6srldcc6r16"
}
