

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-220204092620199906"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testacc-appconf220204092620199906"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_app_configuration_feature" "test" {
  configuration_store_id = azurerm_app_configuration.test.id
  description            = "test description"
  name                   = "acctest-ackey-220204092620199906"
  label                  = "acctest-ackeylabel-220204092620199906"
  enabled                = true

  percentage_filter_value = 10

  timewindow_filter {
    start = "2019-11-12T07:20:50.52Z"
    end   = "2019-11-13T07:20:50.52Z"
  }

  targeting_filter {
    default_rollout_percentage = 39
    users                      = ["random", "user"]

    groups {
      name               = "testgroup"
      rollout_percentage = 50
    }

    groups {
      name               = "testgroup2"
      rollout_percentage = 30
    }
  }
}




resource "azurerm_app_configuration_feature" "import" {
  configuration_store_id = azurerm_app_configuration_feature.test.configuration_store_id
  description            = azurerm_app_configuration_feature.test.description
  name                   = azurerm_app_configuration_feature.test.name
  label                  = azurerm_app_configuration_feature.test.label
  enabled                = azurerm_app_configuration_feature.test.enabled

  percentage_filter_value = 10

  timewindow_filter {
    start = "2019-11-12T07:20:50.52Z"
    end   = "2019-11-12T07:20:50.52Z"
  }

  targeting_filter {
    default_rollout_percentage = 39
    users                      = ["random", "user"]

    groups {
      name               = "testgroup"
      rollout_percentage = 50
    }

    groups {
      name               = "testgroup2"
      rollout_percentage = 30
    }
  }
}
