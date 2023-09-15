
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appserviceplan-230915022839921945"
  location = "West US 2"
}

resource "azurerm_service_plan" "test" {
  name                     = "acctest-SP-230915022839921945"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku_name                 = "P1mv3"
  os_type                  = "Linux"
  per_site_scaling_enabled = true
  worker_count             = 3

  zone_balancing_enabled = true

  tags = {
    environment = "AccTest"
    Foo         = "bar"
  }
}
