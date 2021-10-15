
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appserviceplan-211015014318868480"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                     = "acctest-SP-211015014318868480"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku_name                 = "S1"
  os_type                  = "Linux"
  per_site_scaling_enabled = true
  number_of_workers        = 2

  tags = {
    environment = "AccTest"
    Foo         = "bar"
  }
}
