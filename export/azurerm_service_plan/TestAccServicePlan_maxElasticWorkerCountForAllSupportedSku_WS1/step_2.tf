
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appserviceplan-230316221025072302"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                         = "acctest-SP-230316221025072302"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  sku_name                     = "WS1"
  os_type                      = "Linux"
  maximum_elastic_worker_count = 10

  tags = {
    environment = "AccTest"
    Foo         = "bar"
  }
}
