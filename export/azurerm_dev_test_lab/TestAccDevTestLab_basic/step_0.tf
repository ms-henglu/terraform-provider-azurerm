
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124181600651111"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl221124181600651111"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
