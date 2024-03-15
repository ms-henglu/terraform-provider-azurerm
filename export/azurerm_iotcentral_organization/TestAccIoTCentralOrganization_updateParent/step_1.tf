
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315123226574565"
  location = "West Europe"
}
resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-240315123226574565"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sub_domain          = "subdomain-240315123226574565"
  display_name        = "some-display-name"
  sku                 = "ST0"
}

resource "azurerm_iotcentral_organization" "test_parent" {
  iotcentral_application_id = azurerm_iotcentral_application.test.id
  organization_id           = "org-test-parent-id"
  display_name              = "Org parent"
}
resource "azurerm_iotcentral_organization" "test_parent_2" {
  iotcentral_application_id = azurerm_iotcentral_application.test.id
  organization_id           = "org-test-parent-2-id"
  display_name              = "Org parent 2"
}
resource "azurerm_iotcentral_organization" "test" {
  iotcentral_application_id = azurerm_iotcentral_application.test.id
  organization_id           = "org-test-id"
  display_name              = "Org child"

  parent_organization_id = azurerm_iotcentral_organization.test_parent_2.organization_id
}
