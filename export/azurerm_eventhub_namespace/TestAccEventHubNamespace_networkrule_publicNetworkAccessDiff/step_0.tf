
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eh-240311032121548230"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                          = "acctesteventhubnamespace-240311032121548230"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  sku                           = "Standard"
  capacity                      = "2"
  public_network_access_enabled = true

  network_rulesets {
    default_action                = "Deny"
    public_network_access_enabled = false
    ip_rule {
      ip_mask = "10.0.0.0/16"
      action  = "Allow"
    }
  }
}
