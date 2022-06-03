
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603004804421982"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl220603004804421982"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
