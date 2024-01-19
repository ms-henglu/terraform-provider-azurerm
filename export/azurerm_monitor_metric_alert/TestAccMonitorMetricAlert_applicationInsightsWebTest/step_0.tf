

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025423998970"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestAppInsight-240119025423998970"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_web_test" "test" {
  name                    = "acctestAppInsight-webtest-240119025423998970"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  application_insights_id = azurerm_application_insights.test.id
  kind                    = "ping"
  frequency               = 300
  timeout                 = 60
  enabled                 = true
  geo_locations           = ["us-tx-sn1-azr", "us-il-ch1-azr"]

  configuration = <<XML
<WebTest Name="WebTest1" Id="ABD48585-0831-40CB-9069-682EA6BB3583" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="0" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
  <Items>
    <Request Method="GET" Guid="a5f10126-e4cd-570d-961c-cea43999a200" Version="1.1" Url="http://microsoft.com" ThinkTime="0" Timeout="300" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML
  lifecycle {
    ignore_changes = [tags]
  }
}


resource "azurerm_monitor_metric_alert" "test" {
  name                = "acctestMetricAlert-240119025423998970"
  resource_group_name = azurerm_resource_group.test.name
  scopes = [
    azurerm_application_insights.test.id,
    azurerm_application_insights_web_test.test.id,
  ]
  application_insights_web_test_location_availability_criteria {
    web_test_id           = azurerm_application_insights_web_test.test.id
    component_id          = azurerm_application_insights.test.id
    failed_location_count = 2
  }
  window_size = "PT15M"
  frequency   = "PT1M"
}
