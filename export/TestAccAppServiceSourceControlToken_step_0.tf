
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "3vxchrtbqobhmk4iq4mf9e7ggwoz3ozv18p4x4wpw"
  token_secret = "8tjip0zj187er0bc7hu9zeplbl4bk0l8hu00qsn7s"
}
