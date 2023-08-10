
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810144141548103"
  location = "West Europe"
}
