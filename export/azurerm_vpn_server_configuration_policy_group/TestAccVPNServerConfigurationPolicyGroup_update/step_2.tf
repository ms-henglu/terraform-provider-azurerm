

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230407023833931016"
  location = "West Europe"
}

resource "azurerm_vpn_server_configuration" "test" {
  name                     = "acctestVPNSC-230407023833931016"
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


resource "azurerm_vpn_server_configuration_policy_group" "test" {
  name                        = "acctestVPNSCPG-230407023833931016"
  vpn_server_configuration_id = azurerm_vpn_server_configuration.test.id
  is_default                  = true
  priority                    = 2

  policy {
    name  = "policy2"
    type  = "CertificateGroupId"
    value = "red.com"
  }
}
