
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-220623223722610047"
  location = "West Europe"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-220623223722610047"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  active_directory {
    username            = "aduser"
    password            = "aduserpwd"
    smb_server_name     = "SMBSERVER"
    dns_servers         = ["1.2.3.4"]
    domain              = "westcentralus.com"
    organizational_unit = "OU=FirstLevel"
  }

  tags = {
    "FoO" = "BaR"
  }
}
