package parse

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import (
	"fmt"
	"strings"

	"github.com/hashicorp/terraform-provider-azurerm/helpers/azure"
)

type NetworkAdminRuleCollectionId struct {
	SubscriptionId                 string
	ResourceGroup                  string
	NetworkManagerName             string
	SecurityAdminConfigurationName string
	RuleCollectionName             string
}

func NewNetworkAdminRuleCollectionID(subscriptionId, resourceGroup, networkManagerName, securityAdminConfigurationName, ruleCollectionName string) NetworkAdminRuleCollectionId {
	return NetworkAdminRuleCollectionId{
		SubscriptionId:                 subscriptionId,
		ResourceGroup:                  resourceGroup,
		NetworkManagerName:             networkManagerName,
		SecurityAdminConfigurationName: securityAdminConfigurationName,
		RuleCollectionName:             ruleCollectionName,
	}
}

func (id NetworkAdminRuleCollectionId) String() string {
	segments := []string{
		fmt.Sprintf("Rule Collection Name %q", id.RuleCollectionName),
		fmt.Sprintf("Security Admin Configuration Name %q", id.SecurityAdminConfigurationName),
		fmt.Sprintf("Network Manager Name %q", id.NetworkManagerName),
		fmt.Sprintf("Resource Group %q", id.ResourceGroup),
	}
	segmentsStr := strings.Join(segments, " / ")
	return fmt.Sprintf("%s: (%s)", "Network Admin Rule Collection", segmentsStr)
}

func (id NetworkAdminRuleCollectionId) ID() string {
	fmtString := "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/networkManagers/%s/securityAdminConfigurations/%s/ruleCollections/%s"
	return fmt.Sprintf(fmtString, id.SubscriptionId, id.ResourceGroup, id.NetworkManagerName, id.SecurityAdminConfigurationName, id.RuleCollectionName)
}

// NetworkAdminRuleCollectionID parses a NetworkAdminRuleCollection ID into an NetworkAdminRuleCollectionId struct
func NetworkAdminRuleCollectionID(input string) (*NetworkAdminRuleCollectionId, error) {
	id, err := azure.ParseAzureResourceID(input)
	if err != nil {
		return nil, err
	}

	resourceId := NetworkAdminRuleCollectionId{
		SubscriptionId: id.SubscriptionID,
		ResourceGroup:  id.ResourceGroup,
	}

	if resourceId.SubscriptionId == "" {
		return nil, fmt.Errorf("ID was missing the 'subscriptions' element")
	}

	if resourceId.ResourceGroup == "" {
		return nil, fmt.Errorf("ID was missing the 'resourceGroups' element")
	}

	if resourceId.NetworkManagerName, err = id.PopSegment("networkManagers"); err != nil {
		return nil, err
	}
	if resourceId.SecurityAdminConfigurationName, err = id.PopSegment("securityAdminConfigurations"); err != nil {
		return nil, err
	}
	if resourceId.RuleCollectionName, err = id.PopSegment("ruleCollections"); err != nil {
		return nil, err
	}

	if err := id.ValidateNoEmptySegments(input); err != nil {
		return nil, err
	}

	return &resourceId, nil
}
