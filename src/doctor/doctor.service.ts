import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { slot, SlotDocument } from './schema/slot.schema';
import { AvailabilityDto } from '../auth/dto/availability.dto';
import { generateSlots } from '../utils/slot-generator'; // helper you'll create

@Injectable()
export class DoctorService {
  constructor(
    @InjectModel(slot.name) private slotModel: Model<SlotDocument>,
  ) {}

  async setAvailability(doctorId: string, dto: AvailabilityDto) {
    const slots = generateSlots(dto.from, dto.to);

    const slotDocs = slots.map((slot) => ({
      doctorId,
      from: slot.from,
      to: slot.to,
      status: 'available',
    }));

    await this.slotModel.insertMany(slotDocs);
    return { message: 'Availability slots added successfully', count: slotDocs.length };
  }
}
