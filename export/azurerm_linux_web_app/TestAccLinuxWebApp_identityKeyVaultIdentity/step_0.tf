
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033329317210"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-231016033329317210"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "B1"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-231016033329317210"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_user_assigned_identity" "kv" {
  name                = "acctestUAI-kv-231016033329317210"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_linux_web_app" "test" {
  name                = "acctestWA-231016033329317210"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id, azurerm_user_assigned_identity.kv.id]
  }

  key_vault_reference_identity_id = azurerm_user_assigned_identity.kv.id
}
