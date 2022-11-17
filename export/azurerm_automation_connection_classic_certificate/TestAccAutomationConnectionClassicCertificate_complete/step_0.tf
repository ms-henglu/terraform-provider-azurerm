

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-221117230526248999"
  location = "West Europe"
}

data "azurerm_client_config" "test" {}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-221117230526248999"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_connection_classic_certificate" "test" {
  name                    = "acctestACCC-221117230526248999"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  certificate_asset_name  = "cert1"
  subscription_name       = "subs1"
  subscription_id         = data.azurerm_client_config.test.subscription_id
  description             = "acceptance test for automation connection"
}
