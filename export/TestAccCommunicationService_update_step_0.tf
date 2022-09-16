

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-220916011203844063"
  location = "West Europe"
}


resource "azurerm_communication_service" "test" {
  name                = "acctest-CommunicationService-220916011203844063"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "United States"

  tags = {
    env = "Test"
  }
}
