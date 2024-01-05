
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240105063658507904"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF240105063658507904"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  public_network_enabled = false
}
