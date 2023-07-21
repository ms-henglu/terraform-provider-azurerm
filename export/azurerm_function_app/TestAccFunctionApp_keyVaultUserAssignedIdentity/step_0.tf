
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721020250711579"
  location = "West Europe"
}
resource "azurerm_user_assigned_identity" "test" {
  name                = "acct-230721020250711579"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
resource "azurerm_storage_account" "test" {
  name                     = "acctestsaqb2lr"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-230721020250711579"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}
resource "azurerm_function_app" "test" {
  name                       = "acctest-230721020250711579-func"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  key_vault_reference_identity_id = azurerm_user_assigned_identity.test.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}
