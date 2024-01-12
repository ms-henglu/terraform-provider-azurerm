
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112034303340217"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl240112034303340217"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
