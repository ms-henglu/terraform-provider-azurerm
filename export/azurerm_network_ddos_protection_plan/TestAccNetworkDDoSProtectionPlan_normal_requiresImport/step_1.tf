

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527673018"
  location = "West Europe"
}

resource "azurerm_network_ddos_protection_plan" "test" {
  name                = "acctestddospplan-240119025527673018"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_network_ddos_protection_plan" "import" {
  name                = azurerm_network_ddos_protection_plan.test.name
  location            = azurerm_network_ddos_protection_plan.test.location
  resource_group_name = azurerm_network_ddos_protection_plan.test.resource_group_name
}
