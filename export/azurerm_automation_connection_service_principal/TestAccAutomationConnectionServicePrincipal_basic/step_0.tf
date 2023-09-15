

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-230915022932622284"
  location = "West Europe"
}

data "azurerm_client_config" "test" {}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-230915022932622284"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_connection_service_principal" "test" {
  name                    = "acctestACSP-230915022932622284"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  application_id          = "00000000-0000-0000-0000-000000000000"
  tenant_id               = data.azurerm_client_config.test.tenant_id
  subscription_id         = data.azurerm_client_config.test.subscription_id
  certificate_thumbprint  = file("testdata/automation_certificate_test.thumb")
}
