
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172717563422"
  location = "West Europe"
}
