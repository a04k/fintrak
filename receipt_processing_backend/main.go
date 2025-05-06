package main

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/rs/cors"
)

// Gemini configuration
const (
	GeminiAPIURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
	GeminiAPIKey = "YOUR_GOOGLE_API_KEY" // Set via environment variable in production
)

type GeminiRequest struct {
	Contents []Content `json:"contents"`
}

type Content struct {
	Parts []Part `json:"parts"`
}

type Part struct {
	Text string        `json:"text,omitempty"`
	InlineData *InlineData `json:"inlineData,omitempty"`
}

type InlineData struct {
	MimeType string `json:"mimeType"`
	Data     string `json:"data"`
}

type GeminiResponse struct {
	Candidates []Candidate `json:"candidates"`
}

type Candidate struct {
	Content Content `json:"content"`
}

// Existing structs remain the same...

func processReceipt(imagePath string) (*ScannedExpense, error) {
	// Read image file
	imageData, err := os.ReadFile(imagePath)
	if err != nil {
		return nil, fmt.Errorf("failed to read image: %v", err)
	}

	// Encode image to base64
	encodedImage := base64.StdEncoding.EncodeToString(imageData)

	// Create Gemini request
	req := GeminiRequest{
		Contents: []Content{
			{
				Parts: []Part{
					{
						InlineData: &InlineData{
							MimeType: "image/jpeg",
							Data:     encodedImage,
						},
					},
					{
						Text: `Analyze this receipt and return JSON with these fields:
{
  "merchant": "merchant name",
  "amount": total_amount,
  "date": "YYYY-MM-DD",
  "category": "category_from_list",
  "description": "brief_description",
  "items": [
    {"name": "item1", "quantity": 1, "price": 0.00}
  ]
}

Categories: food, transportation, utilities, entertainment, shopping, health, education, other

Return only valid JSON, no markdown or additional text.`,
					},
				},
			},
		},
	}

	// Marshal request
	reqBody, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %v", err)
	}

	// Create HTTP request
	client := &http.Client{Timeout: 30 * time.Second}
	httpReq, err := http.NewRequest("POST", GeminiAPIURL, bytes.NewBuffer(reqBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %v", err)
	}

	q := httpReq.URL.Query()
	q.Add("key", os.Getenv("GOOGLE_API_KEY")) // Use environment variable in production
	httpReq.URL.RawQuery = q.Encode()
	httpReq.Header.Add("Content-Type", "application/json")

	// Send request
	resp, err := client.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("API request failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("API error: %s - %s", resp.Status, string(body))
	}

	// Parse response
	var geminiResp GeminiResponse
	if err := json.NewDecoder(resp.Body).Decode(&geminiResp); err != nil {
		return nil, fmt.Errorf("failed to decode response: %v", err)
	}

	if len(geminiResp.Candidates) == 0 || len(geminiResp.Candidates[0].Content.Parts) == 0 {
		return nil, fmt.Errorf("no valid response from Gemini")
	}

	// Extract JSON from response
	jsonStr := geminiResp.Candidates[0].Content.Parts[0].Text

	// Parse into ScannedExpense
	var expense ScannedExpense
	if err := json.Unmarshal([]byte(jsonStr), &expense); err != nil {
		return nil, fmt.Errorf("failed to parse Gemini response: %v", err)
	}

	// Validate and sanitize
	expense.ID = uuid.New().String()
	if expense.Date == "" {
		expense.Date = time.Now().Format("2006-01-02")
	}
	if expense.Category == "" {
		expense.Category = Other
	}

	return &expense, nil
}
