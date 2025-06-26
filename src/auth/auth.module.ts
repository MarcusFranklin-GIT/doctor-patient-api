import { Module } from '@nestjs/common';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { MongooseModule } from '@nestjs/mongoose';
import { Doctor, DoctorSchema } from 'src/doctor/doctor.schema';

@Module({
  imports :[
    MongooseModule.forFeature([{name:Doctor.name,schema:DoctorSchema}]),
  ],
  controllers: [AuthController],
  providers: [AuthService]
})
export class AuthModule {}
