

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-communicationservice-230602030237262212"
  location = "West Europe"
}


resource "azurerm_email_communication_service" "test" {
  name                = "acctest-CommunicationService-230602030237262212"
  resource_group_name = azurerm_resource_group.test.name
  data_location       = "United States"
}
