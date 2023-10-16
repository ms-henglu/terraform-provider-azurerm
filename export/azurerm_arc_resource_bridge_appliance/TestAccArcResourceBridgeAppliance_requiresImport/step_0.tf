


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-231016033345226018"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-231016033345226018"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  identity {
    type = "SystemAssigned"
  }
}
