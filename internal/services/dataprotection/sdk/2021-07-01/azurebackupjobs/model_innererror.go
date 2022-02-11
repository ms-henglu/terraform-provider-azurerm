package azurebackupjobs

type InnerError struct {
	AdditionalInfo     *map[string]string `json:"additionalInfo,omitempty"`
	Code               *string            `json:"code,omitempty"`
	EmbeddedInnerError *InnerError        `json:"embeddedInnerError,omitempty"`
}
