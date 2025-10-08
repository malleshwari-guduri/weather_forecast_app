# README

# Weather Forecast App

## Overview
The **Weather Forecast App** is a Ruby on Rails application that allows users to search for real-time weather information by entering a city or location.  
It fetches live weather data from the **OpenWeather API** and displays temperature, humidity, and weather conditions in a clean and interactive UI.  
To improve performance, the app implements **caching for 30 minutes**, ensuring faster subsequent loads for the same location.

---

## Tech Stack
- **Ruby on Rails 6.1.7.10**
- **Ruby 3.1.4**
- **OpenWeather API** for live weather data
- **Redis Cache** (optional)
- **HTML / ERB / CSS** for frontend
- **Bundler & Rails CLI** for dependency and project management

---

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/<your-username>/weather_forecast_app.git
cd weather_forecast_app
