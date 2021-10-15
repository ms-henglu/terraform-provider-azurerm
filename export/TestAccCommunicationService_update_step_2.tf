

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-211015014419242938"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-211015014419242938"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "Australia"

  tags = {
    env = "Test2"
  }
}
