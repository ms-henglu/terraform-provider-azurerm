



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031231477172"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240311031231477172"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-240311031231477172"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "api1"
  path                = "api1"
  protocols           = ["https"]
  revision            = "1"
}

resource "azurerm_api_management_tag" "test" {
  api_management_id = azurerm_api_management.test.id
  name              = "acctest-Tag-240311031231477172"
}

resource "azurerm_api_management_api_tag" "test" {
  api_id = azurerm_api_management_api.test.id
  name   = "acctest-Tag-240311031231477172"
}

resource "azurerm_api_management_api_tag_description" "test" {
  api_tag_id                         = azurerm_api_management_api_tag.test.id
  description                        = "tag description"
  external_documentation_url         = "https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs"
  external_documentation_description = "external tag description"
}

resource "azurerm_api_management_api_tag_description" "import" {
  api_tag_id                         = azurerm_api_management_api_tag_description.test.api_tag_id
  description                        = azurerm_api_management_api_tag_description.test.description
  external_documentation_url         = azurerm_api_management_api_tag_description.test.external_documentation_url
  external_documentation_description = azurerm_api_management_api_tag_description.test.external_documentation_description
}
