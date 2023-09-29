
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064456380902"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-230929064456380902"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_bot_service_azure_bot" "test" {
  name                = "acctestdf230929064456380902"
  resource_group_name = azurerm_resource_group.test.name
  location            = "global"
  sku                 = "F0"
  microsoft_app_id    = data.azurerm_client_config.current.client_id

  microsoft_app_type      = "UserAssignedMSI"
  microsoft_app_tenant_id = data.azurerm_client_config.current.tenant_id
  microsoft_app_msi_id    = azurerm_user_assigned_identity.test.id
}
