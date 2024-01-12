

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112225448126937"
  location = "West Europe"
}

resource "azurerm_static_site" "test" {
  name                = "acctestSS-240112225448126937"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_static_site_custom_domain" "test" {
  static_site_id  = azurerm_static_site.test.id
  domain_name     = "acctestSS-240112225448126937.contoso.com"
  validation_type = "dns-txt-token"
}


resource "azurerm_static_site_custom_domain" "import" {
  static_site_id  = azurerm_static_site.test.id
  domain_name     = "acctestSS-240112225448126937.contoso.com"
  validation_type = "dns-txt-token"
}
