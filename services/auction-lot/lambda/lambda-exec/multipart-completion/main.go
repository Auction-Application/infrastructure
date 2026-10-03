package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/url"

	"multi-part-completion/internal/database/auctionLot"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-secretsmanager-caching-go/secretcache"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
)

var (
	secretCache, _ = secretcache.New()
	// todo make secretName dynamic, maybe from environment variable
	secretName = "rds!db-b6f333a5-ad18-461d-89b7-3b4a8beddf6c"
)

var dbConn *pgx.Conn

func init() {
	secretValue, err := secretCache.GetSecretString(secretName)
	if err != nil {
		panic(fmt.Sprintf("cannot get secretValue %v", err))
	}
	fmt.Println(secretValue)

	var storedSecret storedSecret

	err = json.Unmarshal([]byte(secretValue), &storedSecret)
	if err != nil {
		panic(fmt.Sprintf("cannot unmarshal json %v", err))
	}
	dbConn, err = ConnectToDB(storedSecret)
	if err != nil {
		panic(fmt.Sprintf("cannot connect to db %v", err))
	}

	// dbConn=dbConnection
}

func main() {
	lambda.Start(PollMultiPartCompletionEvent)
}

type storedSecret struct {
	Username string
	Password string
}

func PollMultiPartCompletionEvent(ctx context.Context, event events.SQSEvent) (map[string]any, error) {
	// sqsBatchErrorResponse := map[string]any{
	// 	"batchItemFailures": []map[string]any{
	// 		{"itemIdentifier": nil},
	// 	},
	// }

	// secretValue, err := secretCache.GetSecretString(secretName)
	// if err != nil {
	// 	return sqsBatchErrorResponse, nil
	// }
	// var storedSecret storedSecret

	// err = json.Unmarshal([]byte(secretValue), &storedSecret)
	// if err != nil {
	// 	return sqsBatchErrorResponse, nil
	// }

	batchItemFailures := []map[string]any{}
	eventJson, err := json.Marshal(event)
	if err != nil {
		return nil, err
	}
	fmt.Println(string(eventJson))
	// fmt.Println(event.Records)

	for _, record := range event.Records {
		// fmt.Println(record)
		messageId := processMessage(record)
		if messageId != "" {
			batchItemFailures = append(batchItemFailures, map[string]any{
				"itemIdentifier": messageId,
			})
		}
	}
	fmt.Println("done")
	sqsBatchResponse := map[string]any{
		"batchItemFailures": batchItemFailures,
	}
	fmt.Printf("%+v\n", sqsBatchResponse)
	return sqsBatchResponse, nil
}

func processMessage(record events.SQSMessage) string {
	var s3Event events.S3Event
	err := json.Unmarshal([]byte(record.Body), &s3Event)
	if err != nil {
		return record.MessageId
	}

	for _, s3Record := range s3Event.Records {
		fmt.Println(s3Record.S3.Object.Key)
		objectKeyUUID := uuid.MustParse(s3Record.S3.Object.Key)
		err = auctionLot.New(dbConn).CommitMultiPartUpload(context.TODO(), objectKeyUUID)
		if err != nil {
			return record.MessageId
		}
	}

	// fmt.Printf("Processed message %s\n", record.Body)
	// TODO: Do interesting work based on the new message
	// return nil
	return ""
}

func ConnectToDB(storedSecret storedSecret) (*pgx.Conn, error) {
	// todo make database connection url dynamic, maybe from environment variable
	databaseUrl := fmt.Sprintf("postgres://%s:%s@terraform-c94db1584adb935d6d8f579ab8.cd8cmm6ks70a.ap-south-1.rds.amazonaws.com:5432/auction_db?sslmode=require", storedSecret.Username, url.QueryEscape(storedSecret.Password))
	conn, err := pgx.Connect(context.Background(), databaseUrl)
	if err != nil {
		// fmt.Fprintf(os.Stderr, "Unable to connect to database:%v\n", err)
		// os.Exit(1)
		return nil, err
	}

	// ctx := context.Background()

	// pingErr := conn.Ping(ctx)

	// if pingErr != nil {
	// fmt.Println("Cannot ping to database")
	// os.Exit(1)
	// return nil,err
	// }

	return conn, nil
}
