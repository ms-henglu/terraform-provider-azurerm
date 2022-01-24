
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "48blfycvqcz26vhergdn7i33dqckj020lyfcf8iw1"
  token_secret = "d0x99qfsnuvg83ptpzpacyhpj3pyvnxff4dtnmf1t"
}
