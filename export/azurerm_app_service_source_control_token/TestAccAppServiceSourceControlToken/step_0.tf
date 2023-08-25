
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "mmwdx424lyey784wfi92mnfvb1gubp4h88p6j8oi8"
  token_secret = "i1ybcoqpiwyi0rqvrhcmhhnpqhpysahfczujmwloy"
}
