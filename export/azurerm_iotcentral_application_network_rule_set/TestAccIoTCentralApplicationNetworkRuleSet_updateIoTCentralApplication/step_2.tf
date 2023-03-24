
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230324052212007753"
  location = "West Europe"
}

resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-230324052212007753"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sub_domain          = "subdomain-230324052212007753"

  public_network_access_enabled = false
}

resource "azurerm_iotcentral_application_network_rule_set" "test" {
  iotcentral_application_id = azurerm_iotcentral_application.test.id

  ip_rule {
    name    = "rule1"
    ip_mask = "10.0.1.0/24"
  }

  ip_rule {
    name    = "rule2"
    ip_mask = "10.1.1.0/24"
  }
}
