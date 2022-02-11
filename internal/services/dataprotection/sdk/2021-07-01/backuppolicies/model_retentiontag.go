package backuppolicies

type RetentionTag struct {
	ETag    *string `json:"eTag,omitempty"`
	Id      *string `json:"id,omitempty"`
	TagName string  `json:"tagName"`
}
