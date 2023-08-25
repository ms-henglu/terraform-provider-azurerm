


provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_role_definition" "builtin" {
  name = "Contributor"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mapp-230825024841859888"
  location = "West Europe"
}


resource "azurerm_managed_application_definition" "test" {
  name                = "acctestAppDef230825024841859888"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  lock_level          = "None"
  package_file_uri    = "https://github.com/Azure/azure-managedapp-samples/raw/master/Managed Application Sample Packages/201-managed-storage-account/managedstorage.zip"
  display_name        = "TestManagedApplicationDefinition"
  description         = "Test Managed Application Definition"
  package_enabled     = false
}


resource "azurerm_managed_application_definition" "import" {
  name                = azurerm_managed_application_definition.test.name
  location            = azurerm_managed_application_definition.test.location
  resource_group_name = azurerm_managed_application_definition.test.resource_group_name
  display_name        = azurerm_managed_application_definition.test.display_name
  lock_level          = azurerm_managed_application_definition.test.lock_level
}
