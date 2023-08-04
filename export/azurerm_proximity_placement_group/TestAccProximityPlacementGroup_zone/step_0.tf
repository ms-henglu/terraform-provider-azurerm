
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025626251280"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-230804025626251280"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  allowed_vm_sizes = ["Standard_F2"]
  zone             = "1"
}
