
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072330235669"
  location = "West Europe"

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
