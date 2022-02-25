
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appserviceplan-220225034026652584"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                     = "acctest-SP-220225034026652584"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku_name                 = "P1v2"
  os_type                  = "Linux"
  per_site_scaling_enabled = true
  worker_count             = 3

  tags = {
    Foo = "bar"
  }
}
