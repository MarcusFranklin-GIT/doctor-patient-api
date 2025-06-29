import {IsString, IsEmail, IsStrongPassword} from 'class-validator';

export class DoctorSigninDto{
    @IsEmail()
    email: string; // Doctor's email address

    @IsStrongPassword({
        minLength: 8,
        minLowercase: 1,
        minUppercase: 1,
        minNumbers: 1,
        minSymbols: 1
    })
    password: string;
}