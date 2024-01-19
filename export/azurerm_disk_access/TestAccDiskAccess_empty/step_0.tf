
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024707313381"
  location = "West Europe"
}

resource "azurerm_disk_access" "test" {
  name                = "acctestda-240119024707313381"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}

	