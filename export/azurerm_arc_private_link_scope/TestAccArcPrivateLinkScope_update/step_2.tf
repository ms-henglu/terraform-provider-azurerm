

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034042186573"
  location = "West Europe"
}


resource "azurerm_arc_private_link_scope" "test" {
  name                = "acctestPLS-231016034042186573"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  public_network_access_enabled = false

  tags = {
    "Environment" = "Staging"
  }
}
