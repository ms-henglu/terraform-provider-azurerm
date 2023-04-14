
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "gxpqw3k60n4lwb4rv1jtdqht7f2aigndopjo983pt"
  token_secret = "tf3c1jsgwp87go6p9ll3csp0a41tg8z2784nxo3l6"
}
