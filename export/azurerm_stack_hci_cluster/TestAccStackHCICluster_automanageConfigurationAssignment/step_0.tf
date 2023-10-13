
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231013043011570303"
  location = "West Europe"
}

resource "azurerm_automanage_configuration" "test" {
  name                = "acctest-amcp-231013043011570303"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_stack_hci_cluster" "test" {
  name                        = "acctest-StackHCICluster-231013043011570303"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  client_id                   = data.azurerm_client_config.current.client_id
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  automanage_configuration_id = azurerm_automanage_configuration.test.id

  tags = {
    ENV = "Test"
  }
}
