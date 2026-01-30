# Recipe Spellbook USDA API Proxy

This document describes the API endpoints your server needs to implement to proxy USDA FoodData Central requests.

## Base URL
`https://api.recipespellbook.com` (or your chosen domain)

## Authentication
Your server handles USDA API authentication internally. The app doesn't need to send an API key.

## Endpoints

### 1. Search Foods
Search the USDA database for foods matching a query.

```
GET /usda/search
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | Yes | Search query (e.g., "chicken breast") |
| limit | int | No | Max results (default: 20, max: 50) |
| dataType | string | No | Filter by data type: "Foundation", "SR Legacy", "Survey", "Branded" |

**Response:**
```json
{
  "foods": [
    {
      "fdcId": 173411,
      "description": "Chicken, breast, meat only, cooked, roasted",
      "dataType": "SR Legacy",
      "brandName": null,
      "brandOwner": null,
      "foodCategory": "Poultry Products",
      "servingSize": 100,
      "servingSizeUnit": "g",
      "householdServingFullText": "1 breast half (170g)",
      "foodNutrients": [
        {"nutrientId": 1008, "amount": 165},
        {"nutrientId": 1003, "amount": 31.02},
        {"nutrientId": 1004, "amount": 3.57}
        // ... more nutrients
      ]
    }
  ],
  "totalHits": 1234,
  "currentPage": 1,
  "totalPages": 62
}
```

### 2. Get Food Details
Get detailed information about a specific food.

```
GET /usda/food/{fdcId}
```

**Path Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| fdcId | int | Yes | USDA FDC ID |

**Response:**
```json
{
  "fdcId": 173411,
  "description": "Chicken, breast, meat only, cooked, roasted",
  "dataType": "SR Legacy",
  "foodCategory": "Poultry Products",
  "servingSize": 100,
  "servingSizeUnit": "g",
  "householdServingFullText": "1 breast half (170g)",
  "ingredients": null,
  "foodNutrients": [
    {
      "nutrient": {
        "id": 1008,
        "name": "Energy",
        "unitName": "kcal"
      },
      "amount": 165
    },
    {
      "nutrient": {
        "id": 1003,
        "name": "Protein",
        "unitName": "g"
      },
      "amount": 31.02
    }
    // ... all nutrients
  ]
}
```

### 3. Batch Get Foods (Optional)
Get multiple foods at once.

```
POST /usda/foods
```

**Request Body:**
```json
{
  "fdcIds": [173411, 173410, 168880],
  "nutrients": [1008, 1003, 1004, 1005]  // Optional: only return these nutrients
}
```

**Response:**
```json
{
  "foods": [
    { /* food object */ },
    { /* food object */ },
    { /* food object */ }
  ]
}
```

## Server Implementation (Node.js/Express Example)

```javascript
const express = require('express');
const axios = require('axios');

const app = express();
const USDA_API_KEY = process.env.USDA_API_KEY;
const USDA_BASE = 'https://api.nal.usda.gov/fdc/v1';

// In-memory cache (use Redis in production)
const cache = new Map();
const CACHE_TTL = 24 * 60 * 60 * 1000; // 24 hours

app.get('/usda/search', async (req, res) => {
  try {
    const { query, limit = 20, dataType } = req.query;
    
    // Check cache
    const cacheKey = `search:${query}:${limit}:${dataType || 'all'}`;
    const cached = cache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
      return res.json(cached.data);
    }
    
    // Call USDA API
    const response = await axios.get(`${USDA_BASE}/foods/search`, {
      params: {
        api_key: USDA_API_KEY,
        query,
        pageSize: Math.min(limit, 50),
        dataType: dataType ? [dataType] : undefined,
      }
    });
    
    const data = {
      foods: response.data.foods,
      totalHits: response.data.totalHits,
      currentPage: response.data.currentPage,
      totalPages: response.data.totalPages
    };
    
    // Cache result
    cache.set(cacheKey, { data, timestamp: Date.now() });
    
    res.json(data);
  } catch (error) {
    console.error('USDA search error:', error.message);
    res.status(500).json({ error: 'Failed to search USDA database' });
  }
});

app.get('/usda/food/:fdcId', async (req, res) => {
  try {
    const { fdcId } = req.params;
    
    // Check cache
    const cacheKey = `food:${fdcId}`;
    const cached = cache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
      return res.json(cached.data);
    }
    
    // Call USDA API
    const response = await axios.get(`${USDA_BASE}/food/${fdcId}`, {
      params: { api_key: USDA_API_KEY }
    });
    
    // Cache result
    cache.set(cacheKey, { data: response.data, timestamp: Date.now() });
    
    res.json(response.data);
  } catch (error) {
    console.error('USDA food error:', error.message);
    res.status(500).json({ error: 'Failed to fetch food details' });
  }
});

app.listen(3000, () => console.log('USDA proxy running on port 3000'));
```

## Server Implementation (Go Example)

```go
package main

import (
    "encoding/json"
    "fmt"
    "io"
    "net/http"
    "os"
    "sync"
    "time"
)

var (
    usdaAPIKey = os.Getenv("USDA_API_KEY")
    cache      = make(map[string]cacheEntry)
    cacheMutex sync.RWMutex
)

type cacheEntry struct {
    Data      json.RawMessage
    Timestamp time.Time
}

func searchHandler(w http.ResponseWriter, r *http.Request) {
    query := r.URL.Query().Get("query")
    limit := r.URL.Query().Get("limit")
    if limit == "" {
        limit = "20"
    }

    cacheKey := fmt.Sprintf("search:%s:%s", query, limit)
    
    // Check cache
    cacheMutex.RLock()
    if entry, ok := cache[cacheKey]; ok {
        if time.Since(entry.Timestamp) < 24*time.Hour {
            cacheMutex.RUnlock()
            w.Header().Set("Content-Type", "application/json")
            w.Write(entry.Data)
            return
        }
    }
    cacheMutex.RUnlock()

    // Call USDA API
    url := fmt.Sprintf(
        "https://api.nal.usda.gov/fdc/v1/foods/search?api_key=%s&query=%s&pageSize=%s",
        usdaAPIKey, query, limit,
    )
    
    resp, err := http.Get(url)
    if err != nil {
        http.Error(w, "Failed to search", 500)
        return
    }
    defer resp.Body.Close()

    data, _ := io.ReadAll(resp.Body)
    
    // Cache
    cacheMutex.Lock()
    cache[cacheKey] = cacheEntry{Data: data, Timestamp: time.Now()}
    cacheMutex.Unlock()

    w.Header().Set("Content-Type", "application/json")
    w.Write(data)
}

func main() {
    http.HandleFunc("/usda/search", searchHandler)
    http.HandleFunc("/usda/food/", foodHandler)
    http.ListenAndServe(":3000", nil)
}
```

## Caching Strategy

Since USDA data rarely changes, aggressive caching is recommended:

1. **In-memory cache** for fast access (24-hour TTL)
2. **Database cache** for persistence (store full USDA responses)
3. **Pre-warm cache** with common ingredients on startup

The full 2GB USDA database can be cached on your server for fastest access:
- Download Foundation + SR Legacy datasets
- Import into PostgreSQL/SQLite
- Query your local DB instead of USDA API

## Rate Limiting

USDA API has a limit of 1000 requests/hour. Your proxy should:
- Cache aggressively
- Implement request queuing
- Return cached results when rate limited

## CORS

Enable CORS for your app's domain:
```javascript
app.use(cors({
  origin: ['https://recipespellbook.com', 'capacitor://localhost']
}));
```

## Error Handling

Return consistent error format:
```json
{
  "error": "Error message",
  "code": "ERROR_CODE"
}
```

Common error codes:
- `RATE_LIMITED` - Too many requests
- `NOT_FOUND` - Food not found
- `USDA_ERROR` - USDA API returned an error
- `INVALID_REQUEST` - Bad request parameters