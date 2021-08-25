
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-n-210825045101539479"
  location = "West Europe"
}
resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet210825045101539479"
  address_space       = ["10.0.0.0/16", "ace:cab:deca::/48"]
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}
resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet210825045101539479"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test.name}"
  address_prefixes     = ["10.0.0.0/24", "ace:cab:deca:deed::/64"]
}
