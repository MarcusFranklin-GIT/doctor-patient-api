import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PatientController } from './patient.controller';
import { PatientService } from './patient.service';
import { Doctor, DoctorSchema } from '../doctor/doctor.schema';
import { slot, SlotSchema } from 'src/doctor/schema/slot.schema';
import { appoinment, appoinmentSchema } from 'src/doctor/schema/appoinment.schema';
import { Patient, PatientSchema } from './patient.schema';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Doctor.name, schema: DoctorSchema },
        {name: slot.name, schema: SlotSchema},{name: appoinment.name, schema: appoinmentSchema},{name: Patient.name, schema: PatientSchema}
    ])
  ],
  controllers: [PatientController],
  providers: [PatientService],
})
export class PatientModule {}
