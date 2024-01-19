



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-240119024451797303"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-240119024451797303"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_arc_resource_bridge_appliance" "import" {
  name                    = azurerm_arc_resource_bridge_appliance.test.name
  location                = azurerm_arc_resource_bridge_appliance.test.location
  resource_group_name     = azurerm_arc_resource_bridge_appliance.test.resource_group_name
  distro                  = azurerm_arc_resource_bridge_appliance.test.distro
  infrastructure_provider = azurerm_arc_resource_bridge_appliance.test.infrastructure_provider
  identity {
    type = "SystemAssigned"
  }
}
