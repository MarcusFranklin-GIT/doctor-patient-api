import { ConflictException, Injectable, InternalServerErrorException, UnauthorizedException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import * as bcrypt from 'bcrypt';
import { JwtService } from '@nestjs/jwt';

import { DoctorSignupDto } from './dto/doctor-signup.dto';
import { DoctorSigninDto } from './dto/doctor-signin.dto';
import { Doctor, DoctorDocument } from 'src/doctor/doctor.schema';

import { Patient, PatientDocument } from '../patient/patient.schema';
import { PatientSignupDto, PatientSigninDto } from './dto/patient-signup.dto';
import { access } from 'fs';
import { appoinment, appoinmentDocument } from 'src/doctor/schema/appoinment.schema';

@Injectable()
export class AuthService {
    
    constructor(
        @InjectModel(Doctor.name) 
        private doctorModel: Model<DoctorDocument>,
        @InjectModel(Patient.name) private patientModel:Model<PatientDocument>,
        @InjectModel(appoinment.name) private appointmentModel: Model<appoinmentDocument>,
        private jwtService: JwtService
    ){}
 //for doctors
    // This method is used to sign up the doctor
    async signupDoctor(dto:DoctorSignupDto): Promise<any>{
       try {
        // Validate DTO
        if (!dto.email || !dto.password || !dto.name || !dto.specialization) {
          console.error('Missing required fields:', dto);
          throw new Error('All fields are required');
        }

        // Check for existing email
        const existing = await this.doctorModel.findOne({email:dto.email});
        if(existing) throw new ConflictException('Email already exists');

        // Hash password
        const hashedpassword = await bcrypt.hash(dto.password,10);
        
        // Create new doctor
        const doctor = new this.doctorModel({
            email: dto.email,
            password: hashedpassword,
            name: dto.name,
            specialization: dto.specialization
            // usertype is automatically set to 'doctor' by the schema default
        });

        // Debug output before saving
        console.log('Creating doctor with data:', {
          email: doctor.email,
          name: doctor.name,
          specialization: doctor.specialization,
          usertype: doctor.usertype // automatically set to 'doctor' by schema
        });

        // Save to database
        await doctor.save();
        return {message:'doctor registered successfully'};
    } catch(error){
        console.error('❌ Signup Error:', error);
        
        // Handle specific error types
        if (error.name === 'ValidationError') {
          console.error('Validation error details:', error.errors);
          // Return more specific validation error info
          return { statusCode: 400, message: 'Validation failed', errors: error.errors };
        }
        
        throw error;
    }
    }

    // This method is used to sign in the doctor
    async signinDoctor(dto: DoctorSigninDto){
        try{
            // console.log('received signin DTO:',dto);
        const doctor= await this.doctorModel.findOne({email:dto.email});//finds the doctor by email
        // console.log('doctor found',doctor);
        if(!doctor) throw new UnauthorizedException('Invalid credentials');
            //if the doctor is not found then we throw an error

        const isPasswordValid= await bcrypt.compare(dto.password.toString(),doctor.password);
        // console.log('password valid ?', isPasswordValid);
        if(!isPasswordValid){
            throw new UnauthorizedException('Invalid credentials');
        }//if the password is not valid then we throw an error

        //if the doctor is found and the password is valid then we create a payload
        const payload={
            sub: doctor._id,
            email:doctor.email,
            usertype: doctor.usertype, // Include usertype in JWT token
        };
         console.log('Payload for JWT:', payload);
         // Generate JWT token
         // This is where you can log the payload if needed
        // console.log('📦 JWT Payload:', payload);
         const token= await this.jwtService.signAsync(payload);
        // console.log('✅ Token generated:', token);
         return {
            access_token: token,
            usertype: doctor.usertype,
            message:' doctor Loged-In successfully',
         };
        
    }catch(error){
        console.error('❌ Signin Error:', error);
        throw error;
    }
}


//for patients
        // This method is used to sign up the patient
        async signupPatient(dto:PatientSignupDto){
            try {
                //1 test for existing patient
                const existingPatient = await this.patientModel.findOne({email:dto.email});
                if(existingPatient) {
                    throw new ConflictException('Email already exists');
                }

                //2 hash the password
                const hashedpassword= await bcrypt.hash(dto.password,10);

                //3 create a new patient instance with the hashed password
                const newPatient = new this.patientModel({...dto,password:hashedpassword})
                
                // Debug output before saving
                console.log('Creating patient with data:', {
                  email: newPatient.email,
                  name: newPatient.name,
                  age: newPatient.age,
                  gender: newPatient.gender,
                  usertype: newPatient.usertype // automatically set to 'patient' by schema
                });

                //4 save the patient to the database
                await newPatient.save();
                return {message:'Patient registered successfully'};
            } catch (error) {
                console.error('❌ Signup Error:', error);
                throw error;
            }

        }

        //method for patient signin
        async signinPatient(dto: PatientSigninDto){
            try{
                //1 find the patient by email
                const patient=await this.patientModel.findOne({email:dto.email});

                //2 if patient not found, throw an error
                if(!patient) throw new UnauthorizedException('Invalid Credentials');

                //3 compare the password
                const isPasswordVlaid = await bcrypt.compare(dto.password,patient.password);
                console.log('Password valid?', isPasswordVlaid);

                //4 if password is not valid, throw an error
                if(!isPasswordVlaid){
                    throw new UnauthorizedException('Invalid Credentials');
                }

                //5 create a payload for JWT
                const payload={ 
                    sub:patient._id,
                    email:patient.email,
                    usertype: patient.usertype // Include usertype in JWT token
                };

                //6 generate a JWT token
                const token= await this.jwtService.signAsync(payload);

                return{
                    access_token: token,
                    usertype: patient.usertype,
                    message: 'Patient logged in successfully',
                };
            } catch(error){
                console.error('❌ Signin Error:', error);
                throw new InternalServerErrorException('An error occurred during signin');
            }
        }  
        
        async getAppointments(user: { sub: string, usertype: string }) {
            try{
                let appoinments;
                if(user.usertype =='doctor') {
                    appoinments= await this.appointmentModel.find({doctorId: user.sub}).exec();
                }else{
                    appoinments= await this.appointmentModel.find({patientId: user.sub}).exec();
                }
                if(!appoinments || appoinments.length === 0) {
                    throw new Error('No appointments found for this user');
                }
                return appoinments;
            }catch(error) {
                console.error('❌ Get Appointments Error:', error);
                throw new InternalServerErrorException('An error occurred while fetching appointments');
            }
        }
}
