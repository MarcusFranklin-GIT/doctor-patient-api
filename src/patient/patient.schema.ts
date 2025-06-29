import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type PatientDocument= Patient & Document;
@Schema()
export class Patient{
    @Prop({required:true,unique:true})
    email:string; // Patient's email address - serves as unique identifier

    @Prop({required:true})
    password:string;

    @Prop({required:true})
    name:string;

    @Prop({required:true})
    age: number;

    @Prop({required:true})
    gender:string;

    @Prop({required:true, type: String, default: 'patient'})
    usertype: string;


}

export const PatientSchema=SchemaFactory.createForClass(Patient);
