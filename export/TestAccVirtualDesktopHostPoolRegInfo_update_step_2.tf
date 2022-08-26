
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-220826002635217483"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_host_pool" "test" {
  name                 = "acctestHP01pjz"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  type                 = "Pooled"
  validate_environment = true
  load_balancer_type   = "BreadthFirst"

}

resource "azurerm_virtual_desktop_host_pool_registration_info" "test" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.test.id
  expiration_date = "2022-08-27T00:26:35Z"
}


