

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031533611430"
  location = "West Europe"
}

resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-230106031533611430"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sub_domain          = "subdomain-230106031533611430"
}


resource "azurerm_iotcentral_application_network_rule_set" "test" {
  iotcentral_application_id = azurerm_iotcentral_application.test.id

  default_action = "Deny"
}
