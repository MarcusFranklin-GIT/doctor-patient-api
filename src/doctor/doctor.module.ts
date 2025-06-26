import {Module} from "@nestjs/common";
import { Doctor, DoctorSchema } from "./doctor.schema";
import { MongooseModule } from "@nestjs/mongoose";
import { DoctorController } from './doctor.controller';
import { DoctorService } from './doctor.service';

@Module({
    imports: [
        MongooseModule.forFeature([{ name: Doctor.name, schema: DoctorSchema }]),
    ],
    controllers: [DoctorController],
    providers: [DoctorService],
    exports: [DoctorService],
})
export class DoctorModule{}


