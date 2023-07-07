
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707004117783909"
  location = "West Europe"
}
resource "azurerm_kusto_cluster" "test" {
  name                               = "acctestkc1aprk"
  location                           = azurerm_resource_group.test.location
  resource_group_name                = azurerm_resource_group.test.name
  allowed_fqdns                      = ["255.255.255.0/24"]
  allowed_ip_ranges                  = ["0.0.0.0/0"]
  public_network_access_enabled      = false
  public_ip_type                     = "DualStack"
  outbound_network_access_restricted = true
  sku {
    name     = "Standard_L8s_v3"
    capacity = 2
  }
}
