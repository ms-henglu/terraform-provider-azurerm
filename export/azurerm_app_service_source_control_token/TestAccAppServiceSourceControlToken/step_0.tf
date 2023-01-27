
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "zx2vj264il3sv9hydgl1d1y266hxfzg99dvmwja0k"
  token_secret = "wmpj043ykswfg1yui1f130e967pzh28bjop3sqscb"
}
