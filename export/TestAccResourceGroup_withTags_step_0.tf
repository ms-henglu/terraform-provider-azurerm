
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034626269884"
  location = "West Europe"

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
