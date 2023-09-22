

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-230922054406111738"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-230922054406111738"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}


resource "azurerm_logic_app_integration_account_batch_configuration" "test" {
  name                     = "acctestiabcfjpjn"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name
  batch_group_name         = "TestBatchGroup"

  release_criteria {
    batch_size    = 100
    message_count = 100

    recurrence {
      frequency  = "Month"
      interval   = 1
      start_time = "2021-09-01T01:00:00Z"
      end_time   = "2021-09-02T01:00:00Z"
      time_zone  = "Pacific Standard Time"

      schedule {
        hours      = [2, 3]
        minutes    = [4, 5]
        month_days = [6, 7]

        monthly {
          weekday = "Monday"
          week    = 1
        }
      }
    }
  }

  metadata = {
    foo = "bar"
  }
}
