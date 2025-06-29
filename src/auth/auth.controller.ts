import { Body, Controller, Post, UsePipes, ValidationPipe } from '@nestjs/common';
import { AuthService } from './auth.service';
import { DoctorSignupDto } from './dto/doctor-signup.dto';
import { DoctorSigninDto } from './dto/doctor-signin.dto';
import { PatientSigninDto, PatientSignupDto } from './dto/patient-signup.dto';

@Controller('auth')
export class AuthController {
    constructor(private readonly authService: AuthService){}

     // ------------------ Doctor Routes ------------------
    @Post('doctor/signup')
    @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
    signupDoctor(@Body() dto:DoctorSignupDto){
        return this.authService.signupDoctor(dto);
    }

    @Post('doctor/signin')
    @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
    SigninDoctor(@Body() dto: DoctorSigninDto){
        return this.authService.signinDoctor(dto);
    }
     // ------------------ Patient Routes ------------------

     @Post('patient/signup')
     @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
     signupPatient(@Body() dto: PatientSignupDto ){
        return this.authService.signupPatient(dto);
     }

     @Post('patient/signin')
     @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
     signinPatient(@Body()dto: PatientSigninDto){
        return this.authService.signinPatient(dto);
     }
}

