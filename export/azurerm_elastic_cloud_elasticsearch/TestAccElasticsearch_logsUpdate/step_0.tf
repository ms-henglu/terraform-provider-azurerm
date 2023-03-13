
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-elastic-230313021156591183"
  location = "West Europe"
}

resource "azurerm_elastic_cloud_elasticsearch" "test" {
  name                        = "acctest-estc230313021156591183"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  sku_name                    = "ess-monthly-consumption_Monthly"
  elastic_cloud_email_address = "terraform-acctest@hashicorp.com"

  logs {
    filtering_tag {
      action = "Include"
      name   = "TerraformAccTest"
      value  = "RandomValue230313021156591183"
    }

    # NOTE: these are intentionally not set to true here for testing purposes
    send_activity_logs     = false
    send_azuread_logs      = false
    send_subscription_logs = false
  }
}
