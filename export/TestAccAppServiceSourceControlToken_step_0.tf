
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "244wlvse8xxm0xv0czkc2r7vfz1jluz4h0g38z8t1"
  token_secret = "2xp30t03tpshzgkkmwkrmkjhr0cose6pf4ibhtdr3"
}
