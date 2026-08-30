package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(PollMultiPartCompletionEvent)
}

func PollMultiPartCompletionEvent(ctx context.Context, event events.SQSEvent) (map[string]any, error) {
	batchItemFailures := map[string]any{}
	fmt.Println(event)
	fmt.Println(event.Records)

	for _, record := range event.Records {
		fmt.Println(record)
		err := processMessage(record)
		if err != nil {
			return nil, err
		}
	}
	fmt.Println("done")
	sqsBatchResponse := map[string]any{
		"batchItemFailures": batchItemFailures,
	}
	return sqsBatchResponse, nil
}

func processMessage(record events.SQSMessage) error {
	fmt.Printf("Processed message %s\n", record.Body)
	// TODO: Do interesting work based on the new message
	return nil
}
