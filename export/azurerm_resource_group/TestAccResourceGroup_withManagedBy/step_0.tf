
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929065615633861"
  location = "West Europe"

  managed_by = "test"
}
