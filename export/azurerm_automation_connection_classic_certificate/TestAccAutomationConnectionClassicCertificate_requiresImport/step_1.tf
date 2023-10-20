


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-231020040612480605"
  location = "West Europe"
}

data "azurerm_client_config" "test" {}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-231020040612480605"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_connection_classic_certificate" "test" {
  name                    = "acctestACCC-231020040612480605"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  certificate_asset_name  = "cert1"
  subscription_name       = "subs1"
  subscription_id         = data.azurerm_client_config.test.subscription_id
}


resource "azurerm_automation_connection_classic_certificate" "import" {
  name                    = azurerm_automation_connection_classic_certificate.test.name
  resource_group_name     = azurerm_automation_connection_classic_certificate.test.resource_group_name
  automation_account_name = azurerm_automation_connection_classic_certificate.test.automation_account_name
  certificate_asset_name  = azurerm_automation_connection_classic_certificate.test.certificate_asset_name
  subscription_name       = azurerm_automation_connection_classic_certificate.test.subscription_name
  subscription_id         = azurerm_automation_connection_classic_certificate.test.subscription_id
}
