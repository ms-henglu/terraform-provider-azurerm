
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "z1nfg6z4hstis0a7iqeixoe6tbedrb8fkk9g06r6h"
  token_secret = "izrt1eclspr8eqh2pck90sabyxeqg4eahun24vd3b"
}
