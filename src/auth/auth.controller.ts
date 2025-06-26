import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';
import { DoctorSignupDto } from './dto/doctor-signup.dto';

@Controller('auth/doctor')
export class AuthController {
    constructor(private readonly authService: AuthService){}

    @Post('signup')
    signupDoctor(@Body() dto:DoctorSignupDto){
        return this.authService.signupDoctor(dto);
    }
}

