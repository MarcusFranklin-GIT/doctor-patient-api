import { Body, Controller, Get, Param, Post, Req, UseGuards, UsePipes, ValidationPipe } from "@nestjs/common";
import { JwtAuthGuard } from "../auth/jwt.guard";
import { RolesGuard } from "../common/guards/roles.gaurds";
import { Role } from "../common/decorators/role.decorator";
import { PatientService } from "./patient.service";
import { Request } from 'express';

interface AuthenticatedRequest extends Request {
  user: {
    sub: string;
    usertype: string;
    email: string;
    userId: string;
  };
}


@Controller('patient')
@UseGuards(JwtAuthGuard, RolesGuard)
@Role('patient')
export class PatientController{
    constructor(private readonly patientService: PatientService) {}
    
    @Get('all-doctors')
    @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
    async getAllDoctors(){
        return this.patientService.getAllDoctors();
    }

    @Get('all-doctors/:doctorId/slots')
    @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
    async getDoctorSlots(@Param('doctorId') doctorId: string) {
        return this.patientService.getAvailableSlotsForDoctor(doctorId);
    }

    @Post('book-appointment/:slotId')
    @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
     async bookAppointment(@Param('slotId') slotId: string, @Req() req: AuthenticatedRequest) {
    const patientId = req.user.sub; // sub = MongoDB ObjectId from JWT
    return this.patientService.bookAppointment(slotId, patientId);
    }

}
