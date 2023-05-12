

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010615319569"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl230512010615319569"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_dev_test_lab" "import" {
  name                = azurerm_dev_test_lab.test.name
  location            = azurerm_dev_test_lab.test.location
  resource_group_name = azurerm_dev_test_lab.test.resource_group_name
}
