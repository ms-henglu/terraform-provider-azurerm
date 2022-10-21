

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-221021031402576858"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-221021031402576858"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_log_analytics_query_pack_query" "test" {
  name           = "423ccf84-dc96-42f2-9e0a-850c2ce2777c"
  query_pack_id  = azurerm_log_analytics_query_pack.test.id
  display_name   = "Exceptions - New in the last 48 hours"
  description    = "my test description"
  categories     = ["resources"]
  resource_types = ["microsoft.network/virtualnetworks"]
  solutions      = ["NetworkMonitoring"]

  body = <<BODY
    let newExceptionsTimeRange = 2d;
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
  "Environment2": "Test2"
}
JSON

  tags = {
    my-label       = "label5"
    my-other-label = "label7"
  }
}
