
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "0p1zadamtl334h13ntqtjs1l1l8r0ted4zyxxlkia"
  token_secret = "nubskdwodxazs1tnjbrtsfd0a8aiebfoh34zmmkyi"
}
