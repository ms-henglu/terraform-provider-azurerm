
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-elastic-230512010656989861"
  location = "West Europe"
}

resource "azurerm_elastic_cloud_elasticsearch" "test" {
  name                        = "acctest-estc230512010656989861"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  sku_name                    = "ess-monthly-consumption_Monthly"
  elastic_cloud_email_address = "terraform-acctest@hashicorp.com"

  logs {
    filtering_tag {
      action = "Include"
      name   = "TerraformAccTest"
      value  = "RandomValue230512010656989861"
    }

    # NOTE: these are intentionally not set to true here for testing purposes
    send_activity_logs     = false
    send_azuread_logs      = false
    send_subscription_logs = false
  }
}
