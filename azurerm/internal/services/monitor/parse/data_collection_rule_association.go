package parse

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import (
	"fmt"
	"strings"

	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/azure"
)

type DataCollectionRuleAssociationId struct {
	SubscriptionId     string
	ResourceGroup      string
	VirtualMachineName string
	Name               string
}

func NewDataCollectionRuleAssociationID(subscriptionId, resourceGroup, virtualMachineName, name string) DataCollectionRuleAssociationId {
	return DataCollectionRuleAssociationId{
		SubscriptionId:     subscriptionId,
		ResourceGroup:      resourceGroup,
		VirtualMachineName: virtualMachineName,
		Name:               name,
	}
}

func (id DataCollectionRuleAssociationId) String() string {
	segments := []string{
		fmt.Sprintf("Name %q", id.Name),
		fmt.Sprintf("Virtual Machine Name %q", id.VirtualMachineName),
		fmt.Sprintf("Resource Group %q", id.ResourceGroup),
	}
	segmentsStr := strings.Join(segments, " / ")
	return fmt.Sprintf("%s: (%s)", "Data Collection Rule Association", segmentsStr)
}

func (id DataCollectionRuleAssociationId) ID() string {
	fmtString := "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Compute/virtualMachines/%s/providers/Microsoft.Insights/dataCollectionRuleAssociations/%s"
	return fmt.Sprintf(fmtString, id.SubscriptionId, id.ResourceGroup, id.VirtualMachineName, id.Name)
}

// DataCollectionRuleAssociationID parses a DataCollectionRuleAssociation ID into an DataCollectionRuleAssociationId struct
func DataCollectionRuleAssociationID(input string) (*DataCollectionRuleAssociationId, error) {
	id, err := azure.ParseAzureResourceID(input)
	if err != nil {
		return nil, err
	}

	resourceId := DataCollectionRuleAssociationId{
		SubscriptionId: id.SubscriptionID,
		ResourceGroup:  id.ResourceGroup,
	}

	if resourceId.SubscriptionId == "" {
		return nil, fmt.Errorf("ID was missing the 'subscriptions' element")
	}

	if resourceId.ResourceGroup == "" {
		return nil, fmt.Errorf("ID was missing the 'resourceGroups' element")
	}

	if resourceId.VirtualMachineName, err = id.PopSegment("virtualMachines"); err != nil {
		return nil, err
	}
	if resourceId.Name, err = id.PopSegment("dataCollectionRuleAssociations"); err != nil {
		return nil, err
	}

	if err := id.ValidateNoEmptySegments(input); err != nil {
		return nil, err
	}

	return &resourceId, nil
}
