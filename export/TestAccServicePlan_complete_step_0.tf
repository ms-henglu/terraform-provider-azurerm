
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appserviceplan-211210024305462379"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                     = "acctest-SP-211210024305462379"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku_name                 = "S1"
  os_type                  = "Linux"
  per_site_scaling_enabled = true
  worker_count             = 2

  tags = {
    environment = "AccTest"
    Foo         = "bar"
  }
}
