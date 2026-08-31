package main

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(PollMultiPartCompletionEvent)
}

func PollMultiPartCompletionEvent(ctx context.Context, event events.SQSEvent) (map[string]any, error) {
	batchItemFailures := []map[string]any{}
	eventJson, err := json.Marshal(event)
	if err != nil {
		return nil, err
	}
	fmt.Println(string(eventJson))
	// fmt.Println(event.Records)

	for _, record := range event.Records {
		// fmt.Println(record)
		err := processMessage(record)
		if err != nil {
			return nil, err
		}
	}
	fmt.Println("done")
	sqsBatchResponse := map[string]any{
		"batchItemFailures": batchItemFailures,
	}
	fmt.Printf("%+v\n", sqsBatchResponse)
	return sqsBatchResponse, nil
}

func processMessage(record events.SQSMessage) error {
	var s3Event events.S3Event
	err := json.Unmarshal([]byte(record.Body), &s3Event)
	if err != nil {
		return err
	}

	for _, s3Record := range s3Event.Records {
		fmt.Println(s3Record.S3.Object.Key)
	}

	// fmt.Printf("Processed message %s\n", record.Body)
	// TODO: Do interesting work based on the new message
	return nil
}
