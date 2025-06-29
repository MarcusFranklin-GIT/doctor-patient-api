import {Module} from "@nestjs/common";
import { Doctor, DoctorSchema } from "./doctor.schema";
import { MongooseModule } from "@nestjs/mongoose";
import { DoctorController } from './doctor.controller';
import { DoctorService } from './doctor.service';
import{slot,SlotSchema} from './schema/slot.schema';
@Module({
    imports: [
        MongooseModule.forFeature([{ name: Doctor.name, schema: DoctorSchema },
            { name: slot.name, schema: SlotSchema }]),
    ],
    controllers: [DoctorController],
    providers: [DoctorService],
    exports: [DoctorService],
})
export class DoctorModule{}


