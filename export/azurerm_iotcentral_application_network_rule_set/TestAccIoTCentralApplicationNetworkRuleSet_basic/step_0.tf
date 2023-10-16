

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034046762511"
  location = "West Europe"
}

resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-231016034046762511"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sub_domain          = "subdomain-231016034046762511"
}


resource "azurerm_iotcentral_application_network_rule_set" "test" {
  iotcentral_application_id = azurerm_iotcentral_application.test.id
}
