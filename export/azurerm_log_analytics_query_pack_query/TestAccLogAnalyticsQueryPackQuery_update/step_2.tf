

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-230613072124383047"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-230613072124383047"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_log_analytics_query_pack_query" "test" {
  name           = "5378d38b-9688-496f-b1b8-a19800ff21b4"
  query_pack_id  = azurerm_log_analytics_query_pack.test.id
  display_name   = "Exceptions - New in the last 24 hours"
  description    = "my description"
  categories     = ["network"]
  resource_types = ["microsoft.web/sites"]
  solutions      = ["LogManagement"]

  body = <<BODY
    let newExceptionsTimeRange = 1d;
    let timeRangeToCheckBefore = 7d;
    exceptions
    | where timestamp < ago(timeRangeToCheckBefore)
    | summarize count() by problemId
    | join kind= rightanti (
        exceptions
        | where timestamp >= ago(newExceptionsTimeRange)
        | extend stack = tostring(details[0].rawStack)
        | summarize count(), dcount(user_AuthenticatedId), min(timestamp), max(timestamp), any(stack) by problemId
    ) on problemId
    | order by count_ desc
  BODY

  additional_settings_json = <<JSON
{
  "Environment": "Test"
}
JSON

  tags = {
    my-label       = "label1,label2"
    my-other-label = "label3,label4"
  }
}
