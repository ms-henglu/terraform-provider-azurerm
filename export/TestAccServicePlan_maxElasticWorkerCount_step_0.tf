
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appserviceplan-211015013900759040"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                         = "acctest-SP-211015013900759040"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  sku_name                     = "EP1"
  os_type                      = "Linux"
  maximum_elastic_worker_count = 5

  tags = {
    environment = "AccTest"
    Foo         = "bar"
  }
}
