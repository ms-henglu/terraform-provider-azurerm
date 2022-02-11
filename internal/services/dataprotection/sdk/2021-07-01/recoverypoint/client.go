package recoverypoint

import "github.com/Azure/go-autorest/autorest"

type RecoveryPointClient struct {
	Client  autorest.Client
	baseUri string
}

func NewRecoveryPointClientWithBaseURI(endpoint string) RecoveryPointClient {
	return RecoveryPointClient{
		Client:  autorest.NewClientWithUserAgent(userAgent()),
		baseUri: endpoint,
	}
}
