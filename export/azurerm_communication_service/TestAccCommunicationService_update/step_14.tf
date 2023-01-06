

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-230106034215073103"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-230106034215073103"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "India"

  tags = {
    env = "Test2"
  }
}
