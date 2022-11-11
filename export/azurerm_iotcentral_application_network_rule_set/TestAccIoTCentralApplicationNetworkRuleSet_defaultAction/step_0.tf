

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111020614259399"
  location = "West Europe"
}

resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-221111020614259399"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sub_domain          = "subdomain-221111020614259399"
}


resource "azurerm_iotcentral_application_network_rule_set" "test" {
  iotcentral_application_id = azurerm_iotcentral_application.test.id

  default_action = "Allow"
}
