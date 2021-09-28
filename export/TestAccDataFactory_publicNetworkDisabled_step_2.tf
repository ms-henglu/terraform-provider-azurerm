
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210928055341230724"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF210928055341230724"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  public_network_enabled = false
}
