
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-n-220726015121254867"
  location = "West Europe"
}
resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet220726015121254867"
  address_space       = ["10.0.0.0/16", "ace:cab:deca::/48"]
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}
resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet220726015121254867"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test.name}"
  address_prefixes     = ["10.0.0.0/24"]
}
