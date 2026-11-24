// The routes the Flutter app calls. NestJS forwards them to the Python API.
// Copy this file to: backend/src/python-api/farm.controller.ts
import { Body, Controller, Get, Post, Query, UploadedFile, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { PythonApiService } from './python-api.service';

@Controller('farm')
export class FarmController {
  constructor(private readonly py: PythonApiService) {}

  @Get('health')                 // GET /farm/health
  health() {
    return this.py.health();
  }

  // ---------- Service 1: rainfall + water to add ----------
  @Get('rainfall/options')       // GET /farm/rainfall/options
  rainfallOptions() {
    return this.py.rainfallOptions();
  }

  @Get('water')                  // GET /farm/water?region=Kasserine&crop=potato&start=2026-02&end=2026-06
  water(@Query('region') region: string, @Query('crop') crop: string,
        @Query('start') start: string, @Query('end') end: string) {
    return this.py.waterForecast(region, crop, start, end);
  }

  // ---------- Service 2: soil map ----------
  @Get('soil/options')           // GET /farm/soil/options
  soilOptions() {
    return this.py.soilOptions();
  }

  @Get('soil/map')               // GET /farm/soil/map
  soilMap() {
    return this.py.soilMap();
  }

  @Get('soil/borders')           // GET /farm/soil/borders
  borders() {
    return this.py.governorateBorders();
  }

  @Get('soil/region')            // GET /farm/soil/region?name=Kairouan
  regionSoil(@Query('name') name: string) {
    return this.py.regionSoil(name);
  }

  // ---------- Service 3: crop suitability ----------
  @Get('crops')   // GET /farm/crops?N=90&P=42&K=43&temperature=21&humidity=82&ph=6.5&rainfall=203
  crops(@Query('N') N: string, @Query('P') P: string, @Query('K') K: string,
        @Query('temperature') temperature: string, @Query('humidity') humidity: string,
        @Query('ph') ph: string, @Query('rainfall') rainfall: string) {
    return this.py.predictCrops({ N: +N, P: +P, K: +K, temperature: +temperature,
                                  humidity: +humidity, ph: +ph, rainfall: +rainfall });
  }

  @Get('crops/model')            // GET /farm/crops/model  (accuracy + input ranges)
  cropModel() {
    return this.py.cropModelInfo();
  }

  // ---------- Service 4: market forecast ----------
  @Get('market')                 // GET /farm/market?region=Kairouan&month=3
  market(@Query('region') region = 'Kairouan', @Query('month') month = '3') {
    return this.py.marketOverview(region, Number(month));
  }

  @Get('market/history')         // GET /farm/market/history?product=wheat
  marketHistory(@Query('product') product: string) {
    return this.py.marketHistory(product);
  }

  @Get('market/backtest')        // GET /farm/market/backtest
  marketBacktest() {
    return this.py.marketBacktest();
  }

  // ---------- Service 5: Khiratna chatbot (energy + crop rotation) ----------
  @Post('chat')    // POST /farm/chat   body: { "question": "..." }
  chat(@Body('question') question: string) {
    return this.py.chat(question);
  }

  @Post('stt')     // POST /farm/stt   multipart form-data, field "audio" = the recorded voice -> { "text": "..." }
  @UseInterceptors(FileInterceptor('audio'))
  stt(@UploadedFile() audio: Express.Multer.File) {
    return this.py.speechToText(audio.buffer);
  }
}
