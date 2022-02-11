package backuppolicies

import "github.com/Azure/go-autorest/autorest"

type BackupPoliciesClient struct {
	Client  autorest.Client
	baseUri string
}

func NewBackupPoliciesClientWithBaseURI(endpoint string) BackupPoliciesClient {
	return BackupPoliciesClient{
		Client:  autorest.NewClientWithUserAgent(userAgent()),
		baseUri: endpoint,
	}
}
