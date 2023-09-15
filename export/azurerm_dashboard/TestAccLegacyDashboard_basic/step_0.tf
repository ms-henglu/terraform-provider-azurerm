
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024010342760"
  location = "West Europe"
}

resource "azurerm_dashboard" "test" {
  name                 = "my-test-dashboard"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  dashboard_properties = <<DASH
{
   "lenses": {
        "0": {
            "order": 0,
            "parts": {
                "0": {
                    "position": {
                        "x": 0,
                        "y": 0,
                        "rowSpan": 2,
                        "colSpan": 3
                    },
                    "metadata": {
                        "inputs": [],
                        "type": "Extension/HubsExtension/PartType/MarkdownPart",
                        "settings": {
                            "content": {
                                "settings": {
                                    "content": "## This is only a test :)",
                                    "subtitle": "",
                                    "title": "Test MD Tile"
                                }
                            }
                        }
                    }
				}
			}
		}
	}
}
DASH
}
