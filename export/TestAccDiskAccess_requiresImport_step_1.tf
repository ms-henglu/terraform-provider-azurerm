
	
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623223149307326"
  location = "West Europe"
}

resource "azurerm_disk_access" "test" {
  name                = "acctestda-220623223149307326"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}

	

resource "azurerm_disk_access" "import" {
  name                = azurerm_disk_access.test.name
  location            = azurerm_disk_access.test.location
  resource_group_name = azurerm_disk_access.test.resource_group_name

  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
