

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-220916011203842418"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-220916011203842418"
  resource_group_name = azurerm_resource_group.test.name
}
