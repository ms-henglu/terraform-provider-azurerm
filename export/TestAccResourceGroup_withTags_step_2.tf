
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722052438143890"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
