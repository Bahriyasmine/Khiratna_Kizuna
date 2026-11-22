// Groups the service + controller. Add PythonApiModule to the imports of app.module.ts.
// Copy this file to: backend/src/python-api/python-api.module.ts
import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { PythonApiService } from './python-api.service';
import { FarmController } from './farm.controller';

@Module({
  imports: [HttpModule.register({ timeout: 30000 })],
  providers: [PythonApiService],
  controllers: [FarmController],
  exports: [PythonApiService],   // so other modules (e.g. saving history in PostgreSQL) can use it
})
export class PythonApiModule {}
