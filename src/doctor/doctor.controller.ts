import {
  Controller,
  Post,
  Body,
  UseGuards,
  Req,
  UsePipes,
  ValidationPipe,
  BadRequestException,
  Get,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { RolesGuard } from '../common/guards/roles.gaurds';
import { Role } from '../common/decorators/role.decorator';
import { DoctorService } from './doctor.service';
import { AvailabilityDto } from '../auth/dto/availability.dto';
import { Request } from 'express';

interface AuthenticatedRequest extends Request {
  user: {
    sub: string;
    usertype: string;
  };
}

@Controller('doctor')
export class DoctorController {
  constructor(private readonly doctorService: DoctorService) {}

  @Post('set-availability')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Role('doctor')
  @UsePipes(new ValidationPipe({ 
    whitelist: true, 
    transform: true,
    forbidNonWhitelisted: true,
    exceptionFactory: (errors) => {
      const messages = errors.map(error => 
        Object.values(error.constraints || {}).join(', ')
      );
      throw new BadRequestException({
        message: messages,
        error: 'Validation failed',
        statusCode: 400,
        example: {
          from: '2025-06-29T09:00:00.000Z',
          to: '2025-06-29T17:00:00.000Z'
        }
      });
    }
  }))
  async setAvailability(
    @Req() req: AuthenticatedRequest,
    @Body() dto: AvailabilityDto,
  ) {
    try {
      // Validate that 'to' is after 'from'
      const fromDate = new Date(dto.from);
      const toDate = new Date(dto.to);
      
      if (toDate <= fromDate) {
        throw new BadRequestException('End time must be after start time');
      }
      
      return await this.doctorService.setAvailability(req.user.sub, dto);
    } catch (error) {
      console.error('❌ Set Availability Error:', error);
      throw error;
    }
  }

  @Get('debug-token')
  @UseGuards(JwtAuthGuard)
  async debugToken(@Req() req: AuthenticatedRequest) {
    return {
      message: 'JWT Token Debug Info',
      user: req.user,
      userKeys: Object.keys(req.user || {}),
      usertype: req.user?.usertype,
      sub: req.user?.sub
    };
  }
}
