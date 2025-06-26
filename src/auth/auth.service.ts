import { ConflictException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Doctor, DoctorDocument } from 'src/doctor/doctor.schema';
import { DoctorSignupDto } from './dto/doctor-signup.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
    constructor(
        @InjectModel(Doctor.name) private doctorModel: Model<DoctorDocument>,
    ){}
    async signupDoctor(dto:DoctorSignupDto): Promise<any>{
       try {
        const existing =await this.doctorModel.findOne({doctorId:dto.doctorId});
        if(existing) throw new ConflictException('doctor ID already exists');

        const hashedpassword = await bcrypt.hash(dto.password,10);
        const doctor =new this.doctorModel({
            doctorId: dto.doctorId,
            password:  hashedpassword,
            specialization: dto.specialization
        });

        await doctor.save();//saves to the db 
        return{message:'doctor registered successfully'};
    } catch(error){
        console.error('❌ Signup Error:',error);
        throw error;
    }
    }
}
