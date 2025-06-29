import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document } from "mongoose";

export type DoctorDocument = Doctor & Document; //this is for mondodb to use this schema by a type it can understand
@Schema({ collection: 'doctor' }) 
export class Doctor{ //this export is used in the doctor.module.ts file to import this schema
    @Prop({ required: true ,unique: true})
    email: string; // Doctor's email address - serves as unique identifier

    @Prop({ required: true })
    password: string;
    
    @Prop({required: true})
    name: string;

    @Prop({required: true })
    specialization: string;

    @Prop({default: 'doctor'})
    usertype: string; // This field is used to differentiate between doctor and patient
}

export const DoctorSchema= SchemaFactory.createForClass(Doctor); //this creates or generates the schema mongo db can understand