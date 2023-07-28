

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728032957570775"
  location = "West Europe"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctestrn-230728032957570775"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"
}

resource "azurerm_relay_hybrid_connection" "test" {
  name                 = "acctestrnhc-230728032957570775"
  resource_group_name  = azurerm_resource_group.test.name
  relay_namespace_name = azurerm_relay_namespace.test.name
}


resource "azurerm_relay_hybrid_connection" "import" {
  name                 = azurerm_relay_hybrid_connection.test.name
  resource_group_name  = azurerm_relay_hybrid_connection.test.resource_group_name
  relay_namespace_name = azurerm_relay_hybrid_connection.test.relay_namespace_name
}
