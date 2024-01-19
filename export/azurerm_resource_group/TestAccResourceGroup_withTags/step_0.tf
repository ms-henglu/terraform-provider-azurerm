
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025728750297"
  location = "West Europe"

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
