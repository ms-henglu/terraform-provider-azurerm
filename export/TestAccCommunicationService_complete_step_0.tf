

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-211015014009094826"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-211015014009094826"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "United States"

  tags = {
    env = "Test"
  }
}
