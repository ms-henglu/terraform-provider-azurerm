


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-230106031623609589"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-230106031623609589"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_log_analytics_query_pack_query" "test" {
  query_pack_id = azurerm_log_analytics_query_pack.test.id
  display_name  = "Exceptions - New in the last 24 hours"

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
}


resource "azurerm_log_analytics_query_pack_query" "import" {
  name          = azurerm_log_analytics_query_pack_query.test.name
  query_pack_id = azurerm_log_analytics_query_pack_query.test.query_pack_id
  body          = azurerm_log_analytics_query_pack_query.test.body
  display_name  = azurerm_log_analytics_query_pack_query.test.display_name
}
