
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221104005838190134"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
