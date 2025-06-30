import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document } from 'mongoose';

export type appoinmentDocument =appoinment & Document;

@Schema()
export class appoinment{
    static save() {
        throw new Error("Method not implemented.");
    }

    @Prop({ required: true })
    doctorId:string;

    @Prop({required: true })
    patientId: string; 

    @Prop({required: true })
    slotId: string; 

}

export const appoinmentSchema = SchemaFactory.createForClass(appoinment); //this creates or generates the schema mongo db can understand