
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928075844497391"
  location = "West Europe"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctestrn-210928075844497391"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"
}

resource "azurerm_relay_hybrid_connection" "test" {
  name                          = "acctestrnhc-210928075844497391"
  resource_group_name           = azurerm_resource_group.test.name
  relay_namespace_name          = azurerm_relay_namespace.test.name
  requires_client_authorization = false
  user_metadata                 = "metadataupdated"
}
