
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "w3kah31c7p8cafluzj2hjrva8gutpyxi827os7q1h"
  token_secret = "smoc3jlqrl38cx7h3j3fskuauvj1s9vuuxgjbrpcr"
}
