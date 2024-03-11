
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-240311033021397803"
  location = "West Europe"
}

data "azurerm_template_spec_version" "test" {
  name                = "acctest-standing-data-for-rg"
  resource_group_name = "standing-data-for-acctest"
  version             = "v1.0.0"
}

resource "azurerm_resource_group_template_deployment" "test" {
  name                = "acctest"
  resource_group_name = azurerm_resource_group.test.name
  deployment_mode     = "Incremental"

  template_spec_version_id = data.azurerm_template_spec_version.test.id
}
