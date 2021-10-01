
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001224459936124"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
