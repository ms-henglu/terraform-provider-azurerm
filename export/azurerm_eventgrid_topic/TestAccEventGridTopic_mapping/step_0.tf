
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810143442078077"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-230810143442078077"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  input_schema        = "CustomEventSchema"
  input_mapping_fields {
    data_version = "data"
    event_time   = "time"
    event_type   = "event"
    id           = "id"
    subject      = "subject"
    topic        = "topic"
  }
  input_mapping_default_values {
    data_version = "1.0"
    event_type   = "DefaultType"
    subject      = "DefaultSubject"
  }
}
