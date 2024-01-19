
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527714504"
  location = "West Europe"
}

resource "azurerm_network_ddos_protection_plan" "test" {
  name                = "acctestddospplan-240119025527714504"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_public_ip" "test" {
  name                    = "acctestpublicip-240119025527714504"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  allocation_method       = "Static"
  sku                     = "Standard"
  ddos_protection_mode    = "Enabled"
  ddos_protection_plan_id = azurerm_network_ddos_protection_plan.test.id
}
