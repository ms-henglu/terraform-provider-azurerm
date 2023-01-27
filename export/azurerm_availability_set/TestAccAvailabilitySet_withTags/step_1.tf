
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230127045135587852"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-230127045135587852"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
