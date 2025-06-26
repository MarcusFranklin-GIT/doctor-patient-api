import { IsString, MinLength} from 'class-validator';

export class DoctorSignupDto{
    @IsString()
    doctorId:string;

    @IsString()
    @MinLength(6)
    password:string;

    @IsString()
    specialization:string;
}