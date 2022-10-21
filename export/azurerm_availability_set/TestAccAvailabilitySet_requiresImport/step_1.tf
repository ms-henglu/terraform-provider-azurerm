

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021033910528392"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-221021033910528392"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_availability_set" "import" {
  name                = azurerm_availability_set.test.name
  location            = azurerm_availability_set.test.location
  resource_group_name = azurerm_availability_set.test.resource_group_name
}
