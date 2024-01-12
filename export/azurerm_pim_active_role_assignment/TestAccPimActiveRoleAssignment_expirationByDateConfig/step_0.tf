
data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "test" {}

data "azurerm_role_definition" "test" {
  name = "Workbook Reader"
}

resource "time_static" "test" {}
resource "time_offset" "test" {
  offset_days = 7
}

resource "azurerm_pim_active_role_assignment" "test" {
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = "${data.azurerm_subscription.primary.id}${data.azurerm_role_definition.test.id}"
  principal_id       = data.azurerm_client_config.test.object_id

  schedule {
    start_date_time = time_static.test.rfc3339
    expiration {
      end_date_time = time_offset.test.rfc3339
    }
  }

  justification = "Expiration End Date Set"

  ticket {
    number = "1"
    system = "example ticket system"
  }
}
