
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appserviceplan-211210024305461569"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctest-SP-211210024305461569"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "B1"
  os_type             = "Windows"

  tags = {
    environment = "AccTest"
    Foo         = "bar"
  }
}
