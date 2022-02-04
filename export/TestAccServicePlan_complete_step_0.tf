
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appserviceplan-220204092633693213"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                     = "acctest-SP-220204092633693213"
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
