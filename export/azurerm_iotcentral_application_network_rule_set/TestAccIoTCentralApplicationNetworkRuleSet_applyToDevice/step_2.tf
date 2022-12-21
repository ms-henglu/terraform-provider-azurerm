

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204409085886"
  location = "West Europe"
}

resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-221221204409085886"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sub_domain          = "subdomain-221221204409085886"
}


resource "azurerm_iotcentral_application_network_rule_set" "test" {
  iotcentral_application_id = azurerm_iotcentral_application.test.id

  apply_to_device = true
}
