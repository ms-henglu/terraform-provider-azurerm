

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112034901689685"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-240112034901689685"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestsvwan-240112034901689685"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


data "azurerm_subscription" "current" {}

resource "azurerm_vpn_server_configuration" "test" {
  name                     = "acctestVPNSC-240112034901689685"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  vpn_authentication_types = ["AAD"]

  azure_active_directory_authentication {
    audience = "00000000-abcd-abcd-abcd-999999999999"
    issuer   = "https://sts.windows.net/${data.azurerm_subscription.current.tenant_id}/"
    tenant   = "https://login.microsoftonline.com/${data.azurerm_subscription.current.tenant_id}"
  }
}
