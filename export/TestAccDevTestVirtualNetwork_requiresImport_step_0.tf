
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011408228213"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl220916011408228213"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dev_test_virtual_network" "test" {
  name                = "acctestdtvn220916011408228213"
  lab_name            = azurerm_dev_test_lab.test.name
  resource_group_name = azurerm_resource_group.test.name
}
