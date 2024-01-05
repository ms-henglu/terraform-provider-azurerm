
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060925990427"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-240105060925990427"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  network_rule_set {
    default_action                     = "Allow"
    apply_to_builtin_eventhub_endpoint = true

    ip_rule {
      name    = "test"
      ip_mask = "10.0.0.0/31"
      action  = "Allow"
    }

    ip_rule {
      name    = "test2"
      ip_mask = "10.0.2.0/31"
      action  = "Allow"
    }

  }

  tags = {
    purpose = "testing"
  }
}
