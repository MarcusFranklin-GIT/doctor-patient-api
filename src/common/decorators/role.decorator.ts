import {SetMetadata} from '@nestjs/common';
// This decorator is used to set the role metadata for the route handlers
export const Role=(role:'doctor'|'patient')=> SetMetadata('role',role);
