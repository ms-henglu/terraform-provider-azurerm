
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204060147920365"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-220204060147920365"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  ip_filter_rule {
    name    = "test4"
    ip_mask = "10.0.4.0/31"
    action  = "Accept"
  }

  ip_filter_rule {
    name    = "test"
    ip_mask = "10.0.0.0/31"
    action  = "Accept"
  }

  ip_filter_rule {
    name    = "test3"
    ip_mask = "10.0.3.0/31"
    action  = "Accept"
  }

  ip_filter_rule {
    name    = "test5"
    ip_mask = "10.0.5.0/31"
    action  = "Accept"
  }

  tags = {
    purpose = "testing"
  }
}
