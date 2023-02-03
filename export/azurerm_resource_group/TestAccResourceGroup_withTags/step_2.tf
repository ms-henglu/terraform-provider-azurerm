
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230203064031581737"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
