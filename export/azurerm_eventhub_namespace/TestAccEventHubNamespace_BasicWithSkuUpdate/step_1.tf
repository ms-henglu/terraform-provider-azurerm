
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eh-230915023430051212"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-230915023430051212"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  capacity            = "2"
  network_rulesets {
    default_action = "Deny"
    ip_rule {
      ip_mask = "10.0.0.0/16"
      action  = "Allow"
    }
  }
}
