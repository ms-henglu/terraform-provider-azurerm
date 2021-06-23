package monitor

//go:generate go run ../../tools/generator-resource-id/main.go -path=./ -name=ActionGroup -id=/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/group1/providers/microsoft.insights/actionGroups/actionGroup1
//go:generate go run ../../tools/generator-resource-id/main.go -path=./ -name=ActionRule -id=/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/group1/providers/Microsoft.AlertsManagement/actionRules/actionRule1
//go:generate go run ../../tools/generator-resource-id/main.go -path=./ -name=SmartDetectorAlertRule -id=/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/group1/providers/Microsoft.AlertsManagement/smartdetectoralertrules/rule1
//go:generate go run ../../tools/generator-resource-id/main.go -path=./ -name=DataCollectionRule -id=/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/group1/providers/Microsoft.Insights/dataCollectionRules/rule1
//go:generate go run ../../tools/generator-resource-id/main.go -path=./ -name=DataCollectionRuleAssociation -id=/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/resourceGroups/group1/providers/Microsoft.Compute/virtualMachines/virtualMachine1/providers/Microsoft.Insights/dataCollectionRuleAssociations/association1
//go:generate go run ../../tools/generator-resource-id/main.go -path=./ -name=DataCollectionEndpoint -id=/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/group1/providers/Microsoft.Insights/dataCollectionEndpoints/endpoint1
