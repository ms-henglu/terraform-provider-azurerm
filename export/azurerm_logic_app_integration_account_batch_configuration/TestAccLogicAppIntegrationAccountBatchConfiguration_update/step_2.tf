

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-240105061034191934"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-240105061034191934"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}


resource "azurerm_logic_app_integration_account_batch_configuration" "test" {
  name                     = "acctestiabcb3ev2"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name
  batch_group_name         = "TestBatchGroup"

  release_criteria {
    batch_size    = 110
    message_count = 110

    recurrence {
      frequency  = "Week"
      interval   = 1
      start_time = "2021-09-02T01:00:00Z"
      end_time   = "2021-09-03T01:00:00Z"
      time_zone  = "Pacific SA Standard Time"

      schedule {
        hours     = [3, 4]
        minutes   = [5, 6]
        week_days = ["Monday", "Tuesday"]
      }
    }
  }

  metadata = {
    foo = "bar2"
  }
}
