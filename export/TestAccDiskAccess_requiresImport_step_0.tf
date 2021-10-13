
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013071641530611"
  location = "West Europe"
}

resource "azurerm_disk_access" "test" {
  name                = "acctestda-211013071641530611"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}

	