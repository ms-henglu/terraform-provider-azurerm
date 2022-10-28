
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028171920515577"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testAccCr221028171920515577"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  admin_enabled       = false

  network_rule_set {
    default_action = "Allow"

    ip_rule {
      action   = "Allow"
      ip_range = "8.8.8.8/32"
    }

    ip_rule {
      action   = "Allow"
      ip_range = "1.1.1.1/32"
    }
  }
}
