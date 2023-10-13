
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013044451942977"
  location = "West Europe"
}

resource "azurerm_static_site" "test" {
  name                = "acctestSS-231013044451942977"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_static_site_custom_domain" "test" {
  static_site_id  = azurerm_static_site.test.id
  domain_name     = "acctestSS-231013044451942977.contoso.com"
  validation_type = "dns-txt-token"
}
