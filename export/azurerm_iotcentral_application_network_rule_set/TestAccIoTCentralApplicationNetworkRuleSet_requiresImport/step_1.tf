


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013655272796"
  location = "West Europe"
}

resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-221111013655272796"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sub_domain          = "subdomain-221111013655272796"
}


resource "azurerm_iotcentral_application_network_rule_set" "test" {
  iotcentral_application_id = azurerm_iotcentral_application.test.id
}


resource "azurerm_iotcentral_application_network_rule_set" "import" {
  iotcentral_application_id = azurerm_iotcentral_application_network_rule_set.test.iotcentral_application_id
}
