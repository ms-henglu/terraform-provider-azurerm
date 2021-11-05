
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "dwhmy9f2ay4g76webftuchmtsttmol7ju03jilb8x"
  token_secret = "8wwsbgb89gxjzg319swv1t2eqijp0x8fwrdotptfu"
}
