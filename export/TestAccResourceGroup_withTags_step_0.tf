
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003225103273"
  location = "West Europe"

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
