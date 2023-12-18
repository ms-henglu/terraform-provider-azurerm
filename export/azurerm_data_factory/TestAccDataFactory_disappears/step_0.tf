
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231218071631617221"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF231218071631617221"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
