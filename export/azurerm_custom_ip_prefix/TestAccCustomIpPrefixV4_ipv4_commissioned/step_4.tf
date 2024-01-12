
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112224958132960"
  location = "West Europe"
}

resource "azurerm_custom_ip_prefix" "test" {
  name                = "acctest-240112224958132960"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  cidr  = "194.41.20.0/24"
  zones = ["1"]

  roa_validity_end_date         = "2099-12-12"
  wan_validation_signed_message = "signed message for WAN validation"

  commissioning_enabled         = true
  internet_advertising_disabled = false
}
