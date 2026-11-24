// Calls the Python API (ai-service/app.py) and returns its JSON.
// Copy this file to: backend/src/python-api/python-api.service.ts
import { HttpException, Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class PythonApiService {
  private readonly baseUrl: string;

  constructor(private readonly http: HttpService, config: ConfigService) {
    // .env :  PYTHON_API_URL=http://localhost:8000
    this.baseUrl = config.get<string>('PYTHON_API_URL') ?? 'http://localhost:8000';
  }

  /** GET on the Python API. A wrong input gives a 400 with a clear message from Python. */
  private async get<T = any>(path: string, params: Record<string, unknown> = {}): Promise<T> {
    const clean = Object.fromEntries(Object.entries(params).filter(([, v]) => v !== undefined && v !== ''));
    try {
      const { data } = await firstValueFrom(this.http.get<T>(`${this.baseUrl}${path}`, { params: clean }));
      return data;
    } catch (e: any) {
      if (e.response) throw new HttpException(e.response.data?.detail ?? 'Python API error', e.response.status);
      throw new HttpException(`Python API not reachable at ${this.baseUrl}. Start it: ai-service/start_api.bat`, 503);
    }
  }

  health() {
    return this.get('/api/health');
  }

  // ---------- Service 1: rainfall forecast + water to add ----------
  rainfallOptions() {
    return this.get('/api/rainfall/options');
  }

  /** start / end = 'YYYY-MM' between 2026-01 and 2027-12 */
  waterForecast(region: string, crop: string, start: string, end: string) {
    return this.get('/api/rainfall/forecast', { region, crop, start, end });
  }

  // ---------- Service 2: soil map ----------
  soilOptions() {
    return this.get('/api/soil/options');
  }

  soilMap() {
    return this.get('/api/soil/map');            // GeoJSON, 752 zones
  }

  governorateBorders() {
    return this.get('/api/soil/borders');        // GeoJSON, 24 governorates
  }

  regionSoil(name: string) {
    return this.get('/api/soil/region', { name });
  }

  // ---------- Service 3: crop suitability (AI model, like FarmWise) ----------
  predictCrops(input: { N: number; P: number; K: number; temperature: number; humidity: number; ph: number; rainfall: number }) {
    return this.get('/api/crops/predict', input);
  }

  cropModelInfo() {
    return this.get('/api/crops/model');
  }

  // ---------- Service 4: market forecast ----------
  /** What Tunisia will lack (2027) + what earns the farmer most (water for this governorate / planting month) */
  marketOverview(region: string, plantingMonth: number) {
    return this.get('/api/market/overview', { region, planting_month: plantingMonth });
  }

  /** One product year by year 2000-2027 (chart) */
  marketHistory(product: string) {
    return this.get('/api/market/history', { product });
  }

  marketBacktest() {
    return this.get('/api/market/backtest');
  }

  // ---------- Service 5: Khiratna chatbot (energy + crop rotation) ----------
  /** Khiratna chatbot (RAG + Gemini): energy + crop rotation, English answers, ~1-5 seconds. */
  async chat(question: string) {
    try {
      const { data } = await firstValueFrom(this.http.post(`${this.baseUrl}/api/chat`, { question }, { timeout: 30000 }));
      return data;
    } catch (e: any) {
      if (e.response) throw new HttpException(e.response.data?.detail ?? 'Python API error', e.response.status);
      throw new HttpException(`Python API not reachable at ${this.baseUrl}. Start it: ai-service/start_api.bat`, 503);
    }
  }

  /** Khiratna speech to text (Whisper small on the Python side, English, ~2 seconds). */
  async speechToText(audio: Buffer) {
    try {
      const { data } = await firstValueFrom(this.http.post(`${this.baseUrl}/api/stt`, audio,
        { headers: { 'Content-Type': 'application/octet-stream' }, timeout: 30000, maxBodyLength: 20_000_000 }));
      return data;
    } catch (e: any) {
      if (e.response) throw new HttpException(e.response.data?.detail ?? 'Python API error', e.response.status);
      throw new HttpException(`Python API not reachable at ${this.baseUrl}. Start it: ai-service/start_api.bat`, 503);
    }
  }
}
