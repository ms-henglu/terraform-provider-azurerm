


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230915024139522808"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230915024139522808"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_sentinel_alert_rule_nrt" "test" {
  name                       = "acctest-SentinelAlertRule-NRT-230915024139522808"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  display_name               = "Some Rule"
  severity                   = "High"
  query                      = <<QUERY
AzureActivity |
  where OperationName == "Create or Update Virtual Machine" or OperationName =="Create Deployment" |
  where ActivityStatus == "Succeeded" |
  make-series dcount(ResourceId) default=0 on EventSubmissionTimestamp in range(ago(7d), now(), 1d) by Caller
QUERY
}


resource "azurerm_sentinel_metadata" "test" {
  name                       = "acctest"
  workspace_id               = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  content_id                 = azurerm_sentinel_alert_rule_nrt.test.name
  kind                       = "AnalyticsRule"
  parent_id                  = azurerm_sentinel_alert_rule_nrt.test.id
  providers                  = ["testprovider1", "testprovider2"]
  preview_images             = ["firstImage.png"]
  preview_images_dark        = ["firstImageDark.png"]
  content_schema_version     = "2.0"
  custom_version             = "1.0"
  version                    = "1.0.0"
  threat_analysis_tactics    = ["Reconnaissance", "CommandAndControl"]
  threat_analysis_techniques = ["T1548", "t1548.001"]

  source {
    kind = "Solution"
    name = "test Solution"
    id   = "b688a130-76f4-4a07-bf57-762222a3cadf"
  }

  author {
    name  = "test user"
    email = "acc@test.com"
  }

  support {
    name  = "acc test"
    email = "acc@test.com"
    link  = "https://acc.test.com"
    tier  = "Partner"
  }

  dependency = jsonencode({
    operator = "AND",
    criteria = [
      {
        operator = "OR",
        criteria = [
          {
            contentId = "045d06d0-ee72-4794-aba4-cf5646e4c756",
            kind      = "DataConnector",
          },
          {
            contentId = "dbfcb2cc-d782-40ef-8d94-fe7af58a6f2d",
            kind      = "DataConnector"
          },
          {
            contentId = "de4dca9b-eb37-47d6-a56f-b8b06b261593",
            kind      = "DataConnector",
            version   = "2.0"
          }
        ]
      },
      {
        kind      = "Playbook",
        contentId = "31ee11cc-9989-4de8-b176-5e0ef5c4dbab",
        version   = "1.0"
      },
      {
        kind      = "Parser",
        contentId = "21ba424a-9438-4444-953a-7059539a7a1b"
      }
    ]
  })

}
