
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311042937680202"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
