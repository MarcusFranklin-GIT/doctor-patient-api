import { Module } from '@nestjs/common';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { MongooseModule } from '@nestjs/mongoose';
import { Doctor, DoctorSchema } from 'src/doctor/doctor.schema';
import { JwtModule } from '@nestjs/jwt';
import { Patient, PatientSchema } from 'src/patient/patient.schema';
import { JwtStrategy } from './jwt.strategy';
import { ConfigModule } from '@nestjs/config';
import { PassportModule } from '@nestjs/passport';
import { appoinment, appoinmentSchema } from 'src/doctor/schema/appoinment.schema';
import { slot, SlotSchema } from 'src/doctor/schema/slot.schema';
console.log('JWT_SECRET =', process.env.JWT_SECRET);
@Module({
  imports :[
    MongooseModule.forFeature([{name:Doctor.name,schema:DoctorSchema},
      {name:Patient.name,schema:PatientSchema},{name:appoinment.name,schema:appoinmentSchema},
      {name:slot.name,schema:SlotSchema}
    ]),
    
    JwtModule.register({
      secret:process.env.JWT_SECRET,// Secret key for signing the JWT
      signOptions:{expiresIn:'1h'},// Token will expire in 1 hour
    }),
     PassportModule, ConfigModule
  ],
  controllers: [AuthController],
  providers: [AuthService,JwtStrategy],
   exports: [AuthService]
})
export class AuthModule {}
