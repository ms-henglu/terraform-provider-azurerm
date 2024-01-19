
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527674736"
  location = "West Europe"
}

resource "azurerm_network_ddos_protection_plan" "test" {
  name                = "acctestddospplan-240119025527674736"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
