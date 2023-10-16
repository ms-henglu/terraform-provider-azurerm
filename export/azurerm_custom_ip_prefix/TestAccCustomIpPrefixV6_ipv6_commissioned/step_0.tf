
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034430957040"
  location = "West Europe"
}

resource "azurerm_custom_ip_prefix" "global" {
  name                = "acctest-v6global-231016034430957040"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  cidr = "2620:10c:5001::/48"

  roa_validity_end_date         = "2199-12-12"
  wan_validation_signed_message = "signed message for WAN validation"
}

resource "azurerm_custom_ip_prefix" "regional" {
  name                       = "acctest-v6regional-231016034430957040"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  parent_custom_ip_prefix_id = azurerm_custom_ip_prefix.global.id

  cidr  = cidrsubnet(azurerm_custom_ip_prefix.global.cidr, 16, 1)
  zones = ["1"]
}
