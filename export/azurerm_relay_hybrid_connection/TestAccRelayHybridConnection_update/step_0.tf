
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025720592066"
  location = "West Europe"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctestrn-240119025720592066"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"
}

resource "azurerm_relay_hybrid_connection" "test" {
  name                 = "acctestrnhc-240119025720592066"
  resource_group_name  = azurerm_resource_group.test.name
  relay_namespace_name = azurerm_relay_namespace.test.name
}
