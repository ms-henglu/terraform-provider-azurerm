

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025138145338"
  location = "West Europe"
}


resource "azurerm_arc_private_link_scope" "test" {
  name                = "acctestPLS-240119025138145338"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  public_network_access_enabled = true

  tags = {
    "Environment" = "Production"
  }
}
