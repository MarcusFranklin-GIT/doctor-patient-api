import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document } from "mongoose";

export type DoctorDocument = Doctor & Document; //this is for mondodb to use this schema by a type it can understand
@Schema() 
export class Doctor{ //this export is used in the doctor.module.ts file to import this schema
    @Prop({ required: true ,unique: true})
    doctorId: string;

    @Prop({ required: true })
    password: string;

    @Prop({required: true })
    Specialization: string;

    @Prop({required:true})
    availabileSlots : string[];

    @Prop({required:true})
    bookedSlots:String[];
}

export const DoctorSchema= SchemaFactory.createForClass(Doctor) //this creates or generates the schema mongo db can understand