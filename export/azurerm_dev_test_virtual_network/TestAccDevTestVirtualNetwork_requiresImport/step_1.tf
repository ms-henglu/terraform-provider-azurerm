

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216013437556562"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl221216013437556562"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dev_test_virtual_network" "test" {
  name                = "acctestdtvn221216013437556562"
  lab_name            = azurerm_dev_test_lab.test.name
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_dev_test_virtual_network" "import" {
  name                = azurerm_dev_test_virtual_network.test.name
  lab_name            = azurerm_dev_test_virtual_network.test.lab_name
  resource_group_name = azurerm_dev_test_virtual_network.test.resource_group_name
}
