
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124181401926613"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-221124181401926613"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
