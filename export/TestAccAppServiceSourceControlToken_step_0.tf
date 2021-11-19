
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "ilxn2ipdf4usl9z0v9simpkb0jdbbcyx74jh8aw3v"
  token_secret = "6tpvmfxp7p7hjv3olgc1xmitciqvk6qahozb1isp4"
}
