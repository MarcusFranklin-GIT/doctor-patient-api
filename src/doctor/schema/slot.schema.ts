import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document } from 'mongoose';

export type SlotDocument =slot & Document;

@Schema()
export class slot{

    @Prop({ required: true })
    doctorId:string;

    @Prop({required: true })
    from: Date;

    @Prop({required: true})
    to: Date;

    @Prop({default : 'available'})
    status : string;
}

export const SlotSchema = SchemaFactory.createForClass(slot); //this creates or generates the schema mongo db can understand