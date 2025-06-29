import { IsNotEmpty, IsISO8601 } from 'class-validator';

export class AvailabilityDto {
  @IsNotEmpty({ message: 'Start time (from) is required' })
  @IsISO8601({}, { message: 'Start time (from) must be a valid ISO 8601 date string (e.g., "2025-06-28T10:00:00Z")' })
  from: string; // like "2025-06-28T10:00:00Z"

  @IsNotEmpty({ message: 'End time (to) is required' })
  @IsISO8601({}, { message: 'End time (to) must be a valid ISO 8601 date string (e.g., "2025-06-28T18:00:00Z")' })
  to: string; // like "2025-06-28T18:00:00Z"
}
