
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220819165126689524"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220819165126689524"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "production"
    updated     = "true"
  }
}
