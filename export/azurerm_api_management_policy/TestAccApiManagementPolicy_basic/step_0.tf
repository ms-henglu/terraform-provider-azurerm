
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042832274210"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-231013042832274210"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_policy" "test" {
  api_management_id = azurerm_api_management.test.id
  xml_link          = "https://raw.githubusercontent.com/hashicorp/terraform-provider-azurerm/main/internal/services/apimanagement/testdata/api_management_policy_test.xml"
}
