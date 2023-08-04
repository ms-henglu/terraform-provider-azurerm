
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025626125308"
  location = "West Europe"
}

resource "azurerm_disk_access" "test" {
  name                = "acctestda-230804025626125308"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}

	