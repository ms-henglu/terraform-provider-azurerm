
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227033329463421"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
