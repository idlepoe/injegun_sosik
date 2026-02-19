/**
 * OpenWeatherMap Current Weather Data API 응답 타입 (평면화된 구조)
 * @see https://api.openweathermap.org/data/2.5/weather
 * 
 * 중첩된 구조를 평면화하여 Firestore에 저장
 * weather 배열의 첫 번째 항목만 사용
 */

export interface WeatherData {
  // Coord 필드
  lon: number;
  lat: number;
  
  // WeatherCondition 필드 (첫 번째 항목만)
  weatherId: number;
  weatherMain: string;
  weatherDescription: string;
  weatherIcon: string;
  
  // Main 필드
  temp: number;
  feelsLike: number;
  tempMin: number;
  tempMax: number;
  pressure: number;
  humidity: number;
  seaLevel?: number;
  grndLevel?: number;
  
  // Wind 필드
  windSpeed: number;
  windDeg: number;
  windGust?: number;
  
  // Clouds 필드
  cloudsAll: number;
  
  // Sys 필드
  country: string;
  sunrise: number;
  sunset: number;
  
  // 기타 필드
  base: string;
  visibility: number;
  dt: number;
  timezone: number;
  id: number;
  name: string;
  cod: number;
}

export interface FetchWeatherOptions {
  // 파라미터 없음
}
