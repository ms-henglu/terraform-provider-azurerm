
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "l93vjgb7vpnl3186a0wj8agyvzyp2tp0niew7qw1n"
  token_secret = "0i079j2vh02nnkc81vqf68p30ovxvz2ls3j13yzhp"
}
