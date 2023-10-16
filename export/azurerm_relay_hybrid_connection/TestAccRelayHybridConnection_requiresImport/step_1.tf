

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034621340806"
  location = "West Europe"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctestrn-231016034621340806"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"
}

resource "azurerm_relay_hybrid_connection" "test" {
  name                 = "acctestrnhc-231016034621340806"
  resource_group_name  = azurerm_resource_group.test.name
  relay_namespace_name = azurerm_relay_namespace.test.name
}


resource "azurerm_relay_hybrid_connection" "import" {
  name                 = azurerm_relay_hybrid_connection.test.name
  resource_group_name  = azurerm_relay_hybrid_connection.test.resource_group_name
  relay_namespace_name = azurerm_relay_hybrid_connection.test.relay_namespace_name
}
