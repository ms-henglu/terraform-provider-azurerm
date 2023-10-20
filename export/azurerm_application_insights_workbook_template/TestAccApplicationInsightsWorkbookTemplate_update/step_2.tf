
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231020040453856171"
  location = "West Europe"
}


resource "azurerm_application_insights_workbook_template" "test" {
  name                = "acctest-aiwt-231020040453856171"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  author              = "test author 2"
  priority            = 2

  galleries {
    category      = "workbook"
    name          = "test2"
    order         = 200
    resource_type = "Azure Monitor"
    type          = "workbook"
  }

  template_data = jsonencode({
    "version" : "Notebook/1.0",
    "items" : [
      {
        "type" : 2,
        "content" : {
          "json" : "## New workbook\n---\n\nWelcome to your new workbook."
        },
        "name" : "text - 2"
      }
    ],
    "styleSettings" : {},
    "$schema" : "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
  })

  localized = jsonencode({
    "en-US" : [
      {
        "galleries" : [
          {
            "name" : "test2",
            "category" : "workbook",
            "type" : "workbook",
            "resourceType" : "Azure Monitor",
            "order" : 200
          }
        ],
        "templateData" : {
          "version" : "Notebook/1.0",
          "items" : [
            {
              "type" : 2,
              "content" : {
                "json" : "## New workbook\n---\n\nWelcome to your new workbook."
              },
              "name" : "text - 2"
            }
          ],
          "styleSettings" : {},
          "$schema" : "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
        },
      }
    ]
  })

  tags = {
    key = "value2"
  }
}
