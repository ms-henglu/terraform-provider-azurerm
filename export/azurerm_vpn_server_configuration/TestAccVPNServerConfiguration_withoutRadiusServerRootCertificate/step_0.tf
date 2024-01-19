

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527767167"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-240119025527767167"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestsvwan-240119025527767167"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_vpn_server_configuration" "test" {
  name                     = "acctestVPNSC-240119025527767167"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  vpn_authentication_types = ["Radius"]

  radius {
    server {
      address = "10.105.1.1"
      secret  = "vindicators-the-return-of-worldender"
      score   = 15
    }
  }
}
