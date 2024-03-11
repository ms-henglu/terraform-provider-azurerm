
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032259098085"
  location = "West Europe"
}
resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-240311032259098085"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sub_domain          = "subdomain-240311032259098085"
  display_name        = "some-display-name"
  sku                 = "ST0"
}

resource "azurerm_iotcentral_organization" "test" {
  iotcentral_application_id = azurerm_iotcentral_application.test.id
  organization_id           = "org-test-id"
  display_name              = "Org basic"
}
