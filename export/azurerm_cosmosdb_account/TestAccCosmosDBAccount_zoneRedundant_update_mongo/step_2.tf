
variable "geo_location" {
  type = list(object({
    location          = string
    failover_priority = string
    zone_redundant    = bool
  }))
  default = [
    {
      location          = "westeurope"
      failover_priority = 0
      zone_redundant    = false
    },
    {
      location          = "northeurope"
      failover_priority = 1
      zone_redundant    = true
    }
  ]
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-231020040831273573"
  location = "westeurope"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-231020040831273573"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities {
    name = "EnableMongo"
  }

  enable_multiple_write_locations = true
  enable_automatic_failover       = true

  consistency_policy {
    consistency_level = "Eventual"
  }

  dynamic "geo_location" {
    for_each = var.geo_location
    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      zone_redundant    = geo_location.value.zone_redundant
    }
  }
}
