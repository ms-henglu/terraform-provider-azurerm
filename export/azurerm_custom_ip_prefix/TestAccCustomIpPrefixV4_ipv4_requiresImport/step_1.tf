

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034430954501"
  location = "West Europe"
}

resource "azurerm_custom_ip_prefix" "test" {
  name                = "acctest-231016034430954501"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  cidr  = "194.41.20.0/24"
  zones = ["1"]

  roa_validity_end_date         = "2099-12-12"
  wan_validation_signed_message = "signed message for WAN validation"
}


resource "azurerm_custom_ip_prefix" "import" {
  name                = azurerm_custom_ip_prefix.test.name
  location            = azurerm_custom_ip_prefix.test.location
  resource_group_name = azurerm_custom_ip_prefix.test.resource_group_name

  cidr  = azurerm_custom_ip_prefix.test.cidr
  zones = azurerm_custom_ip_prefix.test.zones

  roa_validity_end_date         = azurerm_custom_ip_prefix.test.roa_validity_end_date
  wan_validation_signed_message = azurerm_custom_ip_prefix.test.wan_validation_signed_message
}
