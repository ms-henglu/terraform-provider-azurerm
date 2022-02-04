
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "n1rg1j0ym1077ov06mcli13v9wgdd9fjfr1ue81sj"
  token_secret = "eu4n74tdupe2zetvadoqjmeze7snd2bcap3dp6mkx"
}
