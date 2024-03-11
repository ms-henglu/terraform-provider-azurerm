

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-rm-240311032742218298"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan-240311032742218298"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctestvhub-240311032742218298"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.1.0/24"
}


resource "azurerm_route_map" "test" {
  name           = "acctestrm-dtomc"
  virtual_hub_id = azurerm_virtual_hub.test.id

  rule {
    name                 = "rule2"
    next_step_if_matched = "Terminate"

    action {
      type = "Replace"

      parameter {
        route_prefix = ["10.0.1.0/8"]
      }
    }

    match_criterion {
      match_condition = "NotContains"
      as_path         = ["223345"]
    }
  }
}
