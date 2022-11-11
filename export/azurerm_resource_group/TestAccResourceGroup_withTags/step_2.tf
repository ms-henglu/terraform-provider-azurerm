
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111021108124201"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
