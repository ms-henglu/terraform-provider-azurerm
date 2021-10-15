
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014725100981"
  location = "West Europe"

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
