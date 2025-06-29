import { IsNotEmpty, IsNumber, IsString, IsEmail, IsStrongPassword } from "class-validator";

export class PatientSignupDto{
    @IsEmail()
    @IsNotEmpty()
    email:string; // Patient's email address

    @IsStrongPassword({
        minLength: 8,
        minLowercase: 1,
        minUppercase: 1,
        minNumbers: 1,
        minSymbols: 1
    })
    @IsNotEmpty()
    password:string;

    @IsString()
    @IsNotEmpty()
    name:string;

    @IsNotEmpty()
    @IsNumber()
    age:number;

    @IsString()
    @IsNotEmpty()
    gender:string;
}

export class PatientSigninDto{
    @IsEmail()
    @IsNotEmpty()
    email:string; // Patient's email address

    @IsStrongPassword({
        minLength: 8,
        minLowercase: 1,
        minUppercase: 1,
        minNumbers: 1,
        minSymbols: 1
    })
    @IsNotEmpty()
    password:string;
}
